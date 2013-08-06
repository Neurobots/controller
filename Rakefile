require 'open-uri'
require 'json'
require 'pp'


desc "Cache the running botlist"
task :cache_botlist do
 PID = Process.pid 
 botlist = JSON.parse(open('http://www.neurobots.net/status').read)
 start_url = "http://www.neurobots.net/status/LJaETkMFyHCGVBFHU3uDjelMoVra6qL7rIEgHZdecDjcRXNN2hAjHWHh7n3Y8T88qKxCsjx7dk1T3ccyNKQ/start/"
 File.open("botlist", "w") { |file| file.write(open('http://www.neurobots.net/status').read) }
end
