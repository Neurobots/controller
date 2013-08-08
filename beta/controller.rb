#!/usr/bin/env ruby

require 'rubygems'
require 'base32'
require 'sinatra'
require 'mysql'
require 'json'
require 'pp'
require 'sys/proctable'

include Sys

PHK = 'LJaETkMFyHCGVBFHU3uDjelMoVra6qL7rIEgHZdecDjcRXNN2hAjHWHh7n3Y8T88qKxCsjx7dk1T3ccyNKQ'

# Functions

# Prove the key is good
def validate_key(id,magickey)
end

# Pull the key for the backdoor
def get_key(id)
end

# Start bot
def start_bot(id,magickey)
end

# Stop bot
def stop_bot(id,magickey)
end

# Status
def status(id,magickey)
end

# Lookups

get '/' do
	"Controller Online"
end

# Backdoor Start
get "/#{PHK}/start/:id" do |id|
	"Backdoor start called with id #{id}"
	#start_bot(id,get_key(id))
end

# Backdoor Stop
get "/#{PHK}/stop/:id" do |id|
	"Backdoor stop called with id #{id}"
	#bop_bot(id,get_key(id))
end

# Backdoor Status
get "/#{PHK}/status/:id" do |id|
	"Backdoor status called with id #{id}"
	#status(id,get_key(id))
end

# Global stats
get "/status" do
	output  = "Controller stats\n"
	ProcTable.ps { |process| output += PP.pp(process,"") if process.comm.match(/ruby/) } 
  return output
end

# Start
get "/start/:hash" do |hash|
	id, key = JSON.parse(Base32.decode(hash))
	"Start called with id #{id} and hash of #{key}"
	#start_bot(id,key)
end

# Stop
get "/stop/:hash" do |hash|
  id, key = JSON.parse(Base32.decode(hash))
  "Stop called with id #{id} and hash of #{key}"
  #stop_bot(id,key)
end

# Status
get "/status/:hash" do |hash|
  id, key = JSON.parse(Base32.decode(hash))
  "Status called with id #{id} and hash of #{key}"
  #status(id,key)
end







