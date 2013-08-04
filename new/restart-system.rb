#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'pp'

botlist = JSON.parse(open('http://www.neurobots.net/status').read)
start_url = "http://www.neurobots.net/status/LJaETkMFyHCGVBFHU3uDjelMoVra6qL7rIEgHZdecDjcRXNN2hAjHWHh7n3Y8T88qKxCsjx7dk1T3ccyNKQ/start/"

File.open("botlist", "w") { |file| file.write(open('http://www.neurobots.net/status').read) }

#`pkill -9 ruby*`

sleep 3

# botlist.each do |bot|

#	open(start_url+bot['userid']).read

# end

