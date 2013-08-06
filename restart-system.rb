#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'pp'

PID = Process.pid 

botlist = JSON.parse(open('http://www.neurobots.net/status').read)
start_url = "http://www.neurobots.net/status/LJaETkMFyHCGVBFHU3uDjelMoVra6qL7rIEgHZdecDjcRXNN2hAjHWHh7n3Y8T88qKxCsjx7dk1T3ccyNKQ/start/"

File.open("botlist", "w") { |file| file.write(open('http://www.neurobots.net/status').read) }

`ps -aef | grep ruby`.split("\n").each do |lineinput|

        listing = lineinput.split(/\s+/)
        listing[12] = '' if listing[12].nil?
        # pp 'Found Mine' if listing[1].match(/#{PID}/)
        #pp  listing[1] if listing[12].match(/grep/)
        `kill -9 #{listing[1]}` if (!listing[1].match(/#{PID}/))and(!listing[12].match(/grep/))
end

sleep 3

 botlist.each do |bot|

       open(start_url+bot['userid']).read

 end


