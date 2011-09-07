--- 
:drupal_id: 9
:date: 1215350240
:type: story
:title: Setting up your system for file conversions with File Framework
:format_id: 1
:format: Filtered HTML
:slug: 2008/07/setting-your-system-file-conversions-with-file-framework
---
An important requirement of the platform for SPAWAR (for whom my employer, <a href=http://openband.net>Openband</a>, works)  is a set of full-featured file functionality.  Our solution to that is <a href="http://groups.drupal.org/user/8735">Miglius'</a> <a href="http://drupal.org/project/fileframework">File Framework</a>, which is an exceedingly powerful solution for handling files on a Drupal 6 site.  It reqires <a href=http://bendiken.net>Arto's</a> <a href=http://drupal.org/project/resource>RDF Framework</a>, which means it's easy for other modules to interact with it, and has a ton of other features, but the one I'm writing about today is the file conversion bits.  Out of the box, FF supports logic for tons of conversion paths, so anything your users upload is downloadable as a preview, as a full file, playable in the browser, viewable as html, whatever.  Importantly, it uses OpenOffice to do all of those nifty office format conversions:  viewing Word documents in the browser, inline, is exceedingly useful.

It'd be silly to write that much conversion code yourself, and naturally we didn't want to reinvent the wheel.  But that means there's a ton of software to install to make all of this work, from PHP 5.2 to JOD Converter, and that's what this post is about.
<!--break-->
I will quickly get out of the way that this is not something intended for shared hosting.  Good shared hosting will actually have a lot of this stuff installed already, and you'll just need to find the path, but documenting building all of this in non-privileged space is not what I'm after.

Also of note, all of this was done on <a href="http://centos.org">CentOS 5</a>.  I think it would be easier on Debian or Ubuntu, as some of these software bits that needed to be built manually because of CentOS's occasionally dated packages.  A great example is RHEL5/CentOS's inexplicable PHP 5.1.6.  The resource framework requires PHP 5.2, and several months ago I rolled up a PHP 5.2.4 package based on the RHEL package, removing patches that had been fixed in the delta between 5.1.6 and 5.2.4 and keeping the rest.  It works exactly like the RHEL/CentOS one does, except the version doesn't suck.  If you're using CentOS or RHEL and PHP, you thus may want to download <a href="http://bhuga.net/files/php-5.2.4-spawar1.src.rpm">this PHP RPM</a>.

First of all, you'll need the PECL Fileinfo package.  This is a normal PECL installation:
<pre style="overflow:auto">
# pecl install Fileinfo
</pre>

Packages should exist for <a href="http://ffmpeg.mplayerhq.hu/">ffmpeg</a>, <a href="http://ftp.wagner.pp.ru/~vitus/software/catdoc/">catdoc</a>, <a href="http://www.swftools.org/">swftools</a>, <a href="http://www.gnu.org/software/unrtf/unrtf.html">unrtf</a>, and <a href="http://www.foolabs.com/xpdf/download.html">pdftotext</a> (contained within poppler-utils on CentOS, and part of the Xpdf project):
<pre style="overflow:auto"> 
# yum install -y swftools unrtf poppler-utils catdoc 
</pre>

CentOS's <a href="http://pages.cs.wisc.edu/~ghost/">Ghostscript</a> package is simply too old, but briefly installing it will take care of the numerous dependecies.  Snag a copy of the tarball and install like so:
<pre style="overflow:auto">
# yum -y install ghostscript
# rpm -e ghostscript
# cd ghostscript-8.62
# ./configure --prefix=/opt/ghostscript --exec-prefix=/opt/ghostscript
# make
# make install
</pre> 

Note that this will require some path changes to the File Framework conversion configuration settings, unless you add Ghostscript to your web server's path.

Probably the most troublesome bit is OpenOffice.  First you'll need a JRE, and a recent one; if your OS doesn't come with a 1.6 package it's easily obtained from <a href=http://java.sun.com/javase/downloads/index.jsp>Sun</a>.  Most importantly, you need a i386 package: <a href="http://www.fedoraforum.org/forum/showthread.php?t=169065">OpenOffice is buggy on x86_64.</a>

OpenOffice itself is probably the roughest part.  The packages don't really support the idea of a 'headless converter' functionality, and CentOS isn't helping.  As I keep my servers as slim as possible, I needed to install a ton of X libraries to get things going.  In addition, OpenOffice requires a Java tzdata package that isn't available for CentOS, but the Fedora Core 8 version works fine.
<pre style="overflow:auto>
# yum install -y libX11.i386 libXext.i386 libXi.i386 libXtst.i386 asound.i386 libfreetype.i386
# yum install -y freetype.i386 alsa-lib.i386 libpng.i386 libjpeg.i386 giflib.i386 libSM.i386
# rpm -i tzdata-java-2008c-1.fc8.noarch.rpm
# rpm -i java-1.6.0-openjdk-1.6.0.0-0.7.b08.el5.2.i386.rpm
</pre>

Now, install all of the OpenOffice pacakges.  don't try and install fewer: it simply won't work.  Converting .xls to .odt requires the entire graphical calc package to be installed.  You can get the whole shebang, a collection of .rpm's in a .tgz, from <a href="http://download.openoffice.org/other.html#en-US">OpenOffice.org</a>.  The only packages that should fail are the gnome/kde bits.

To use that OpenOffice goodness, you'll need to run it like a daemon.  I've slightly modified the init script found <a href="http://www.oooforum.org/forum/viewtopic.phtml?t=62031">here</a> to our use, in that can run as an unprivileged user, and in particular, as a user that the web server can work with.  Copy and paste from below or wget <a href="http://bhuga.net/files/openoffice.rc">this link</a>:
<pre style="overflow:auto">
#!/bin/bash
#
# chkconfig: 35 96 4
# description: Open Office
#

#Source function library.
. /etc/init.d/functions

export OOUSER=apache
export DISPLAY=0.0
export HOME=/home/${OOUSER}
export PATH=$PATH
export LANG=en_US.UTF-8

start() {
echo -n "Starting OpenOffice service: "
sudo -u $OOUSER env HOME=$HOME /opt/openoffice.org2.4/program/soffice -headless -accept="socket,port=8100;urp" -nofirststartwizard -display $DISPLAY &
### touch the lock file ###
touch /var/lock/subsys/soffice
success $"OpenOffice startup"
echo
}

stop() {
echo -n "Stopping soffice: "
killproc soffice
### Remove the lock file ###
rm -f /var/lock/subsys/soffice
echo
}

case "$1" in
start)
start
;;
stop)
stop
;;
status)
status soffice
;;
restart|reload|condrestart)
stop
start
;;
*)
echo $"Usage: $0 {start|stop|restart|reload|status}"
exit 1
esac

exit 0 
</pre>

Lastly, you need a command line tool to interface with OpenOffice.  <a href="http://www.artofsolving.com/opensource/jodconverter">JOD Converter</a> handles that, and that's what we use.  There's also a <a href=http://www.artofsolving.com/opensource/pyodconverter>python version</a> if that floats your boat.  There's no RPM for it, but just snag a tarball from <a href="http://sourceforge.net/project/showfiles.php?group_id=91849">the downloads area</a>, it's just a .jar file.  I put it in /opt/jodconverter.  Like ghostscript, this will require editing File Framework's conversion settings unless you put it in the web server's path.

Enjoy your multiply-converted file goodness!
