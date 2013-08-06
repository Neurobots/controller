# Controller


Getting Started
--------------

- clone the git repository
- run `bundle install`
- hack away
- commit changes and push to master
- see deployment


Deployment
----------

- Requires a SSH key from the deploy user Joshua to be in ~/.ssh/joshua_deploy_key

After your commit cycle, and you've got changes in MASTER ready to be published, run the publish.sh script.

Explanation:
- It kicks off a rake task to cache the bot list
- Executes a capistrano deployment task
- - Capistrano deployment checks out the MASTER branch 
- - Symlinks from controller/vx/releases to controller/vx/current
- - Sanitizes the directory by removing the excess directories that rails requires
- - Issues a restart via restart-system.rb

Modify Major Revision Numbers
-----------------------------

in config/deploy.rb there is a definition for deploy_to that has /vx at the end. Modify this verison number for major releases.



Running tasks independently
---------------------------

To cache the botlist manually, issue `rake cache_botlist`

To issue a deploy without caching the botlist, run `cap deploy`
