#!/usr/bin/env ruby

##############################################
#
# Neurobots websocketProxy.rb
#
# This isn't to be released
#
# We use this to fire everything else
#
##############################################

# Change these to make things unique

require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'base64'
require 'open-uri'
require 'pp'
require 'evma_httpserver'
require 'stringio'
#require 'ponder'
require 'json'
require 'mysql'

$db = Mysql::new("hal", "nirvana_neurobot", "571b7c5a6fe4", "neurobots")


def irc_start_bot ( userid, magicKey )

if $bots.any? {|h| h["userid"] == userid}
                                                # ws.send "\@"+($bots.find {|bot| bot['magicKey'] = magicKey})['port'].to_s
						# bot is already running
                                        else
                                        testPort = rand($internalPortEnd - $internalPortStart) + $internalPortStart

                                        while $bots.any? {|h| h["port"] == testPort} do
                                                testPort = rand($internalPortStart..$internalPortEnd)
                                        end
                                        if $bots.any? {|h| h["userid"] == userid}
                                                # ws.send "\@"+($bots.find {|bot| bot['magicKey'] = magicKey})['port'].to_s
                                        else
                                                pid = spawn($rvm_env_vars.merge({ "BOTPORT" => testPort.to_s, "MAGICKEY" => magicKey, "BOTUSERID" => userid}), "~/neuroserver/bot/current/websocketProxy.rb")
                                                        puts "Spawning bot on #{testPort}\n"
                                                        # ws.send "\@#{testPort}"
                                                        $bots.push(Hash[ "port", testPort, "magicKey", magicKey, "userid", userid, "pid", pid ])
                                        end
                                        end
end


  class MyHttpServer < EM::Connection
    include EM::HttpServer

     def post_init
       super
       no_environment_strings
     end

    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers
	magicHardKey = 'LJaETkMFyHCGVBFHU3uDjelMoVra6qL7rIEgHZdecDjcRXNN2hAjHWHh7n3Y8T88qKxCsjx7dk1T3ccyNKQ'
      response = EM::DelegatedHttpResponse.new(self)
      response.status = 200
      response.content_type 'text/html'
	#this is fucked.
	botlist = Marshal.load( Marshal.dump($bots) )
	# botlist = $bots.clone
	botlist.each { |bot| bot.delete('magicKey') }
	response.content = ''
      if ( @http_request_uri =~ /#{magicHardKey}/ ) 
	# response.content << " Jackbot "
		if ( @http_request_uri =~ /#{magicHardKey}\/restart/ )
			response.content << "restart works"
			EventMachine::Timer.new(1) do
   				`pkill -9 ruby*`
                		exit 0
				end
			end

                if ( @http_request_uri =~ /#{magicHardKey}\/stop/ )
                        response.content < "stop works"
			 botid = @http_request_uri.gsub( /^.+#{magicHardKey}\/stop\//, '')                        
				$bots.each do |bot|
                                                if bot['userid'] == botid
                                                       Process.kill("TERM",bot["pid"])
                                                        Process.detach(bot["pid"])
                                                        response.content << "Killing Pid: #{bot['pid']}"
                                                        end

				end
				$bots.delete_if {|h| h['userid'] == botid }
			end
	
		if ( @http_request_uri =~ /#{magicHardKey}\/start/ )
			botid = @http_request_uri.gsub( /^.+#{magicHardKey}\/start\//, '')
			magic_key = ""
        		#lookup magic key
                	$db.query("select magic_key from users where bot_userid='#{botid}' LIMIT 1").each do |row|
                                magic_key = row[0]
                                end
                      	controller = 'a' 
                        $db.query("update users set controller='#{controller}' where bot_userid='#{botid}'")
                        irc_start_bot(botid, magic_key)
                        response.content << "Starting #{botid} #{magic_key}"
                                                                                
			end
	
	else
      response.content << JSON.dump(botlist)
	end	
      response.send_response
    end
  end



$rvm_env_vars = { 
		 "GEM_HOME" 		=> ENV['GEM_HOME'],
		 "GEM_PATH" 		=> ENV['GEM_PATH'],
		 "HISTFILE" 		=> ENV['HISTFILE'],
		 "IRBRC"    		=> ENV['IRBRC'],
		 "MY_RUBY_HOME" 	=> ENV['MY_RUBY_HOME'],
		 "PATH" 		=> ENV['PATH'],
		 "RUBY_VERSION" 	=> ENV['RUBY_VERSION'],
		 "rvm_env_string" 	=> ENV['rvm_env_string'],
		 "rvm_bin_path" 	=> ENV['rvm_bin_path'],
		 "rvm_path"   		=> ENV['rvm_path'],
		 "rvm_prefix" 		=> ENV['rvm_prefix'],
		 "rvm_ruby_string" 	=> ENV['rvm_ruby_string'],
		 "rvm_version" 		=> ENV['rvm_version']
		}

$internalPortStart = 30100
$internalPortEnd   = 30300
$bots = []

websocketIp = '127.0.0.1'
websocketPort = '30000'

#websocketIp = ENV['OPENSHIFT_INTERNAL_IP'] if ENV.include? 'OPENSHIFT_INTERNAL_IP'

puts "#{websocketIp} #{websocketPort}"


EM.run {

EM.start_server websocketIp, 30001, MyHttpServer

EventMachine.add_periodic_timer(10) do
	pp $bots
end

  EM::WebSocket.run(:host => websocketIp, :port => websocketPort, :debug => false) do |ws|
    isAuth = false
    ws.onopen { |handshake|
      puts "WebSocket opened #{{
        :path => handshake.path,
        :query => handshake.query,
        :origin => handshake.origin,
      }}"

      ws.send "ACTIVATED"
    }

    ws.onmessage { |msg|
	if isAuth
        function = msg.match(/^~~(\d)/)	
        function = function[1] if !function.nil?
	if !function.nil?
	pp function
		case function
			when /1/
				ws.send "Function 1"
				userid, magicKey = msg.scan(/^~~\d\$\$(.+)\$\$(.+)\$\$$/).shift.shift(2)
				if [userid,magicKey].all? 
					if $bots.any? {|h| h["userid"] == userid}
                                                ws.send "\@"+($bots.find {|bot| bot['magicKey'] = magicKey})['port'].to_s
					else
					testPort = rand($internalPortEnd - $internalPortStart) + $internalPortStart
				
					while $bots.any? {|h| h["port"] == testPort} do
						testPort = rand($internalPortStart..$internalPortEnd)
					end
					if $bots.any? {|h| h["userid"] == userid} 
                                                ws.send "\@"+($bots.find {|bot| bot['magicKey'] = magicKey})['port'].to_s
					else	
						pid = spawn($rvm_env_vars.merge({ "BOTPORT" => testPort.to_s, "MAGICKEY" => magicKey, "BOTUSERID" => userid}), "~/neuroserver/bot/current/websocketProxy.rb")
							puts "Spawning bot on #{testPort}\n"
							ws.send "\@#{testPort}"	
							$bots.push(Hash[ "port", testPort, "magicKey", magicKey, "userid", userid, "pid", pid ])
					end
					end
				else
					ws.send "Data format error"
				end
				# pp bots 
				
			when /2/
				ws.send "Function 2"
				userid, magicKey = msg.scan(/^~~\d\$\$(.+)\$\$(.+)\$\$$/).shift.shift(2)
                                if [userid,magicKey].all?
					$bots.each do |bot|
						if bot['userid'] == userid && bot['magicKey'] == magicKey
							Process.kill("TERM",bot["pid"])
							Process.detach(bot["pid"])
							p "Killing Pid: " + bot['pid'].to_s
							ws.send("#")
							end
					end
					$bots.delete_if {|h| h['userid'] == userid && h['magicKey'] == magicKey }	
				else
					ws.send "Data format error"
                                end
			when /3/
				ws.send "Function 3"
                                userid, magicKey = msg.scan(/^~~\d\$\$(.+)\$\$(.+)\$\$$/).shift.shift(2)
                                if [userid,magicKey].all?
					if $bots.any? { |bot| bot['magicKey'].eql?(magicKey)&&bot['userid'].eql?(userid) }
						ws.send "\@"+($bots.find {|bot| bot['magicKey'] == magicKey})['port'].to_s  
					else
						ws.send "#"
					end
				else
                                        ws.send "Data format error"
                                end
			else
				ws.send "Function format error"
			end
			
		else
	                        ws.send "Data format error"

		end	
		else
			        function = msg.match(/^(.+)\|(.+)$/)
				if !function.nil?
				#this is ugly as hell
				#this needs to change to a json call which means profile.php needs to be updated on the other side......
				eval '$botProfileX = ' + Base64.decode64(open("http://www.neurobots.net/websockets/profile.php?userid=#{function[1]}&magic_key=#{function[2]}").first)	
			  	#botProfile = $botProfile #Complete work around to get it back in scope before something nasty happens
				botProfile = Marshal.load( Marshal.dump($botProfileX) )
				pp botProfile
				isAuth = true if botProfile.has_key? "magic_key"
					# If were authed to speak, and the bot is running return it's port
					if isAuth && $bots.any? { |bot| bot['magicKey'].eql? botProfile['magic_key'] }
                                                ws.send "\@"+($bots.find {|bot| bot['magicKey'] == botProfile['magic_key']})['port'].to_s
                                        else
                                                ws.send "#"
                                        end
				else
					ws.send "Auth Error"
				end
	
		end					
    }
    ws.onclose {
      puts "WebSocket closed"
    }
    ws.onerror { |e|
      puts "Error: #{e.message}"
    }
  end
}

