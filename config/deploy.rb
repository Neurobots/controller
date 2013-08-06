default_run_options[:pty] = true
default_run_options[:shell] = "bash"


#update this to v2 when you reach a new major release
set :deploy_to, "/home/joshua/neuroserver/controller/v1"
set :current_path, "#{deploy_to}/current"
set :shared_path, "#{deploy_to}/shared"

#deployment user configuration
set :user, "joshua"
set :use_sudo, false
set :ssh_options, { forward_agent: true, paranoid: true, keys: "~/.ssh/joshua_deploy_key" }

#set the endpoint
role :app, "dev.neurobots.net"                          # This may be the same as your `Web` server


#version control
set :scm, :git 
set :branch, "master"
set :repository,  "git@github.com:Neurobots/controller.git"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"


namespace :deploy do
  #override the restart deployment routine
  task :restart, :except => { :no_release => true } do
   #puts "nothing to restart"  
   #run "ruby #{current_path}/restart_system.rb"
  end

  #since we aren't deploying via file copy, wipe the cruft
  task :sanitize, :except => { :no_release => true } do
    run "rm -rf #{current_path}/public"
    run "rm -rf #{current_path}/log"
    run "rm -rf #{current_path}/tmp"
    run "rm -rf #{current_path}/config"
  end
end

 #nothing to see here - figlet did all the hard work
 task :brand do
   puts "****     **                                 **                 **          "
   puts "/**/**   /**                                /**                /**         " 
   puts "/**//**  /**  *****  **   ** ******  ****** /**       ******  ******  ******"
   puts "/** //** /** **///**/**  /**//**//* **////**/******  **////**///**/  **//// "
   puts "/**  //**/**/*******/**  /** /** / /**   /**/**///**/**   /**  /**  //***** "
   puts "/**   //****/**//// /**  /** /**   /**   /**/**  /**/**   /**  /**   /////**"
   puts "/**    //***//******//******/***   //****** /****** //******   //**  ****** "
   puts "//     ///  //////  ////// ///     //////  /////    //////     //  //////  "
  end

#Callbacks
after "deploy", "deploy:sanitize", :brand


