--- 
:drupal_id: 37
:date: 1236538532
:type: story
:title: Import/Export BoF at Drupalcon 2009 DC
:format_id: 2
:format: Full HTML
:slug: 2009/03/importexport-bof-drupalcon-2009-dc
---
My food poisoning at DCDC (don't eat rare meat in DC!) abated just long enough for me to attend an excellent BoF towards the end of Friday at <a href="http://dc2009.drupalcon.org">Drupalcon DC 2009</a>.  The goal was workable configuration management in <a href="http://drupal.org">Drupal</a>, and in no particular order, attending were:

<ul>
  <li> <a href="http://drupal.org/user/1337">Adrian Roussouw</a>, author of Forms API
  <li><a href="http://drupal.org/user/68275">Bala Bosch</a>, <a href="http://drupal.org/user/70716">Chrys Bryant</a> and <a href="http://drupal.org/user/70352">Sarva Bryant</a>, authors of <a href="http://drupal.org/project/patterns">Patterns</a></li>
  <li><a href="http://drupal.org/user/128537">Greg Dunlap</a>, author of the <a href="http://drupal.org/project/deploy">deployment framework</a></li>
  <li><a href="http://www.developmentseed.org/team/young-hahn">Young Hahn</a> and <a href="http://www.developmentseed.org/team/jeff-miccolis">Jeff Miccolis</a>, who gave us the <a href="http://drupal.org/project/context">context</a> and <a href="http://drupal.org/project/spaces">spaces</a> projects</li>
   <li><a href="http://drupal.org/user/49989">Bevan Rudge</a>, who wrote <a href="http://drupal.org/project/c2c">config to code</a></li>
</ul>  

In terms of configuration management, having these folks in a room is a bit like the G7, but with Voltron attending.

In addition, one or two more interested parties showed up, including myself (I've tried to limit rattling off names to people who contributed to the projects listed; if I missed one, sorry).  <a href="http://openbandlabs.com">Openband</a> is trying to stand up our stack with more than 200 modules, and configuration management is probably our biggest challenge right now.  We'll be applying some resources to the problem and want to make sure that whatever solution happens is one that provides us a workable upgrade path for the future.

Probably the biggest trick about all of this is separating what's needed from the use cases.  It's difficult to separate what really needs to happen from the end result, and the community is so quick to jump on any potential solution to this widespread problem that it's hard to work on something that enables solutions without talking about solutions.  The short version of what needs to happen is that 'each module needs to do its own part', but there's no straightforward answer.  

Going over my notes, the discussion had two main themes: requirements and implementation.

<h3>Requirements</h3>

<h5>Context and Dependencies</h5>
The context module does something really sweet, in that it provides a 'context' for a page load or a feature (a 'space' from the spaces module is more or less a context definition for a feature).  This is an important idea, in that it maps settings to functionality and not to modules.  It was generally agreed that this idea needs to be incorporated in any end solution, but perhaps not agreed that it was core's job to deal with it.  Along related lines, there was also some question on whether or not core should handle ideas like dependencies, and I believe the general consensus was no.

<h5>Roadmap</h5>
Most everyone agreed that nobody wants to throw D6 to the wolves, and that the solution should come in the form of a hook/hooks added to D6 in contrib which can hopefully be added to D7 core.  In either case, anything that builds on these hooks is a contrib space thing--this hook needs to be implemented by core, but won't be called by it.  So the degree to which D6/D7 get supported after the hook's implementation can be left up to whoever has the resources and inclination to do it.

<h5>Limitations</h5>
Related to roadmap, we need to be cognizant of what we're doing.  It would be easy to replace a Data API by being too broad--the truth is that config and content have no inherent difference (what's a group, after all?).  The Data API (or something else) should eventually take care not only of this problem, but of the content problem as well.  Thus, this is not something that will live forever, nor is it something that will be perfect.  It will pick some low-hanging fruit in the problem space, and do it broadly, but it's not going to be all things to all people.  This is frustrating, as where to draw the line between 'config' and 'data' is something that varies from site to site and it's going to be a problem for people for whom the line is drawn just a tad bit off.

<h3>Implementation</h3>
<h5>Hooks in contrib6/core7, the rest in contrib</h5>
It was generally agreed upon is that there needs to be some kind of hook, or set of hooks, that *each module* can implement.  The work needs to be associated with each module, so that it only need be done once.  The exact nature of that hook has some argument left; there are two basic paths, outlined below.  There's also consideration for a hook_default_config hook.

<h5>A self-consuming API?</h5>
One idea is that modules simply export a configuration and import it: a module can eat whatever it outputs.  But this turns out to be a Godzilla task for most modules to implement.  Forms API has a couple of layers of validation in a couple of places, some of which, such as what kind of data something is, or whether it's in a list of allowed values, is never implemented by a developer.  Such a high-level import/export API would force modules to write specific validation for everything, and a lot of modules would need to refactor custom validation from form code into reusable code.  But even that would not be enough--thanks to the magic of form_alter, modules do not even necessarily know what consists of a valid configuration for themselves!  To match existing functionality 100%, we'd have to have a hook_export_alter and hook_import_alter to allow modules to clobber each other as much as they already do.  Thus, not only would each module need to implement the hook, it would have to re-alter every module it already does.  Fun stuff!

<h5>Is Forms API the API?</h5>
The only API that *every* drupal module supports is Forms API.  Everyone's a bit nervous about this, since the Forms API does not technically support macros, and even if it did, it's not the best way to visualize configuration for a module; a pretty form does not automatically transfer to a data structure.  But as things stand, this is the only API that is 100% compatible.

<h3>Current Implementations</h3>

<h5>Context / Spaces </h5>
Spaces is a module that provides context for a feature, with import/export functionality.  I understood that it implements its config import/export mostly on its own, without using Forms API.  Associating features with a context allows them to be quickly enabled or disabled, or for modules/themes to change their behavior based on the context , and probably more.  I need to play with this more.

<h5>Patterns</h5>
Gravitek Labs have written Patterns, which convert snippets of YAML and XML into Form API calls.  They have support for most of core, plus views and cck, and it's fairly trivial to write patterns for modules that don't support it by identifying fields in their forms.

They have also started some work on something called the Configuration Framework for D6, which appears to be a standardized way to write data for Forms API and some magic for processing it.  It provides some hooks for modules to implement which are a bit like import/export, but designed to provide input to their forms.  It's also got the idea that modules should be able to ship with their default config in a text file.  It uses patterns as the representation of config, which means it can be XML or YAML (with more to come).

<h5>Deployment Framework</h5>
Greg Dunlap uses both methods (for some things he used drupal_execute, others not).  Much of the deployment framework is solving another problem, however, content, and I think it was generally agreed that this system should not attempt to create a layer that would be used for passing around content.  It's a significantly more complicated problem anyway, as Greg discovered when he added a lot of things I suspect the Data API folks will end up having to do anyway, in particular indexing content by both auto-incremented id's *and* unique identifiers.

<h3>All the rest</h3>

Other issues were mentioned, including, but not limited to, the D7 variables patch, and context and how important it is (solving, for example, the global uid problem), 

At any rate, we agreed that the next phase of deliverables are:
 <ul>
  <li>An import-export API for discussion</li>
  <li>A best-practices document to describe how to write exportable modules</li>
 </ul>
