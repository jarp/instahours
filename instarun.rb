#!/usr/bin/env ruby

case ARGV[0].to_s
  when "time"
    puts "run time runner"
    exec 'ruby time.rb'
  when "notes"
    puts "run notes runner"
    exec 'ruby notes.rb'
  else
    exec 'ruby hours.rb'
end
