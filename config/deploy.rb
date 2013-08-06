default_run_options[:pty] = true
default_run_options[:shell] = "bash"


set :deploy_to, "/home/chuck/controller"
set :current_path, "#{deploy_to}/public_html"
set :shared_path, "#{deploy_to}/shared"

set :user, "chuck"
set :use_sudo, false
set :ssh_options, { forward_agent: true, paranoid: true, keys: "~/.ssh/id_rsa" }

role :app, "dev.neurobots.net"                          # This may be the same as your `Web` server


set :scm, :git 
set :repository,  "git@github.com:Neurobots/controller.git"

set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules", "Capfile", "config/deploy.rb"]

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"


namespace :deploy do
  task :restart, :except => { :no_release => true } do
   #puts "nothing to restart"  
   run "ruby #{current_path}/restart_system.rb"
  end

  task :reset_owner, :except => { :no_release => true } do
    run "#{sudo} chown -R www-data:www-data #{current_path}"
  end

end

namespace :file do
  task :permissions do
    
  end
end


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
after "deploy", "file:permissions", "deploy:reset_owner", :brand


