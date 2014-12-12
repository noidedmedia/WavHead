#!/usr/bin/env ruby
require 'optparse'
require 'sinatra/base'
require_relative './lib/db'
require_relative './lib/wav_head_player'
require_relative './lib/wav_head_info'
require_relative './lib/wav_head_server'
require_relative './lib/wav_head_vote_manager'
opts = {}
OptionParser.new do |o|
  o.banner = "Usage: wav_head.rb [options]"
  o.on("-s", "--server", "Run a server") do |v|
    opts[:server] = true
  end
  o.on("-p", "--port PORT", Integer, "Run on a specific port") do |p|
    opts[:port] = p
  end
  o.on("-i", "--index [DIR]", "Index a directory") do |i|
    opts[:index] = i
  end
  o.on("-l", "--list", "List all songs") do |l|
    opts[:list] = true
  end
  o.on("-d", "--delete", "Delete the database") do |d|
    opts[:delete] = true
  end

end.parse!

WavHead::Info.setup(opts[:index]) if opts[:index]
puts WavHead::Info.pretty_print if opts[:list]
WavHead::Info.delete! if opts[:delete]
if opts[:server]
  puts "Starting a server..." 
  require 'yaml'
  WavHead::Server.set :p, WavHead::Player.new
  config = YAML.load_file "config.yml"
  WavHead::Server.set :votemanager, WavHead::VoteManager.new(config)
  puts WavHead::Server.settings.votemanager.inspect
  WavHead::Server.settings.p.start!
  WavHead::Server.set :port, opts[:port] if opts[:port]
  WavHead::Server.set :bind, "0.0.0.0"
  WavHead::Server.run!
end
