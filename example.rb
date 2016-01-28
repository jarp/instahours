#!/usr/bin/ruby -w
require_relative 'instahours'
system 'clear'

instahours = InstaHours.new

entries = instahours.entries_for
time = instahours.time_for_in_hours
puts "Total time logged is  #{time} "
puts "There are #{entries.count} time entries"

entries.each do | entry |
  puts "#{entry["date"]} | #{entry["project-name"]} >> #{entry["hours"]}h #{entry["minutes"]}m "
end

instahours.complete
