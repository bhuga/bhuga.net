--- 
:date: 1336361712
:type: story
:title: XHR Uploading directly to S3 with a Ruby Backend
:format_id: 4
:format: Markdown
:slug: xhr-uploading-directly-to-s3-with-a-ruby-backend
---

I just spent a couple of days on a journey of discovery regarding uploading
files directly to S3. It's pretty straightforward unless you don't want to
refresh the page on upload. There are a few gotchas when learning about this,
so I wanted to write up a quick post that combines the why with the how. It
should be useful no matter what you want to build regarding this stuff.

### Gotcha 1: HTML5 won't work.

HTML5 XHR form uploads require an `Access-Control-Allow-Origin` header
from the server and S3 won't give it to you. It will work if you can accept a
redirect on upload, but we don't want to refresh the page.

So you'll need a flash uploader. [SWFUpload](http://swfupload.org/) will do the trick just fine.

The initial setup ought to look something like this. It's in [Coffeescript](http://coffeescript.org).

    @swfu = new SWFUpload
              flash_url: "<%= asset_path 'swfupload.swf' %>"
              file_queue_limit:1
              upload_url: "http://<%= configatron.aws.cms.bucket %>.s3.amazonaws.com"
              button_placeholder_id : "SWFUploadButton"
              button_action: SWFUpload.BUTTON_ACTION.SELECT_FILE
              button_width: '112'
              button_height: '33'
              button_text: '<span class="swfuploadbutton">Choose an MP3</span>',
              button_cursor : SWFUpload.CURSOR.HAND
              http_success : [201, 303, 200]
              file_post_name: "file"
              file_queued_handler: (data) =>
                @queued(data)
              upload_complete_handler: (data) =>
                console.log "upload's done, if anyone cares."
              upload_start_handler: (data) =>
                console.log "upload started, if anyone cares."
              upload_error_handler: (data, data2, data3) ->
                console.log "error uploading."
              upload_progress_handler: (f, c, t) ->
                console.log "consider this a progress bar update."
              upload_success_handler: (data, data2, data3) ->
                console.log "hooray!"

We're interested in the `file_queued_handler`. After a file is queued, we know
its name, and we can create a pre-signed post for it to be pushed straight to
S3. However, our Amazon keys only exist on the backend, so we need the backend
to create some of the form parameters for us.

    queued: (file) -> $.ajax
        url: '/uploads/new'
        data: { key: @key(file.name), bucket: '<%= configatron.aws.cms.bucket %>' }
        success: (data) =>
          @upload(data)

I've got a little UploadController that basically just signs any filename that
a user with an admin cookie asks for; it lives at `/uploads/new`. It looks
something like this (not actually what I run):

    # This code won't actually work; see below.
    key = params[:filename]
    bucket = AWS::S3.new.buckets(params[:bucket])
    policy = bucket.presigned_post(key: key, success_action_status: 201, acl: 'public-read')
    render json: policy.fields

This won't actually work, because of...

### Gotcha 2: Flash adds a form parameter to uploads.

Every ActionScript uploader adds a `Filename` parameter to the form associated
with file uploads over HTTP. A few stackoverflow answers claim it can't be
removed, and I didn't bother to investigate, as I have no AS dev environment
going. Unless the `Filename` parameter is accounted for in the post signature,
S3 will return a 403. Worse, many flash uploaders will hide the body of the
error response, making this one tricky to debug. [Here's a stackoverflow example of this silly field.](http://stackoverflow.com/questions/2116514/does-flash-always-post-a-filename-parameter-when-doing-a-file-upload)

So we need to add a parameter to the presigned post:

    policy = bucket.presigned_post(key: key, success_action_status: 201, acl: 'public-read')
                      .where(:filename).starts_with('')

This creates a different policy, in which the filename parameter can be
anything. But this fails too, because of...

### Gotcha 3: The aws-sdk gem does not support the filename parameter

Shoot. The aws-sdk gem does not support adding fields that S3 does not
directly support. S3 will simply ignore `Filename`, so we could build our own
policy if we wanted, but I'd rather let Amazon's official SDK do the Base64
rigamarole.

So I [forked the
gem](https://github.com/bhuga/aws-sdk-for-ruby/tree/allow-filenames-as-post-parameter),
and added support. It looks like this in a Gemfile:

    gem 'aws-sdk', '1.3.2', :git => 'git://github.com/bhuga/aws-sdk-for-ruby.git', :ref => 'allow-filenames-as-post-parameter'

There is also a [pull
request](https://github.com/amazonwebservices/aws-sdk-for-ruby/pull/43) but
it's been a few workdays with no response, so who knows.

Okay, back to Javascript. Remember our `queued` function?

    queued: (file) -> $.ajax
        url: '/uploads/new'
        data: { key: @key(file.name), bucket: '<%= configatron.aws.cms.bucket %>' }
        success: (data) =>
          @upload(data)

It references an `upload` function, which should look something like this. The
`data` being returned will be the JSON output of the upload signer above.

    upload: (data) ->
      @swfu.setPostParams data
      console.log "uploading...."
      @swfu.startUpload()

This tells SWFUpload to start uploading, bringing us to...

### Gotcha 4: You need a crossdomain.xml file in the target S3 bucket.

Again, a malformed crossdomain.xml file will result in more-or-less silent
failures in your favorite flash uploader. Sigh. They're fairly simple to add to
your bucket. [Here's a stackoverflow 
example](http://stackoverflow.com/questions/213251/can-someone-post-a-well-formed-crossdomain-xml-sample).

After adding the crossdomain.xml, you're good to go.

If you still have trouble, I recommend [ngrep](http://ngrep.sourceforge.net/),
which is pretty awesome at letting you sniff local http traffic and look at
error responses that naughty flash widgets hide from you.

Whew. Have fun.

