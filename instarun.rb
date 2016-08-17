#!/usr/bin/env ruby
require_relative 'runner'
require_relative 'time_runner'

case ARGV[0].to_s
  when "time"
    puts "run time runner"
    exec 'ruby time.rb'
  when "notes"
    puts "run notes runner"
    exec 'ruby notes.rb'
  else
    exec 'ruby run.rb'
end
