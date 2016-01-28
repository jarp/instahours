require 'highline/import'
require_relative 'instahours'

instahours = InstaHours.new
project = instahours.default_project

system 'clear'

puts "TeamWork InstaHours\n==========================================\n\n"

puts "Hi there #{instahours.default_person}. Your default project seems to be '#{project}'."

continue = ask("Is your name and project correct? (y/n)") { |q| }


if continue == 'y'

  puts "\n\nAwesome!\n"
  puts "Here are your time entries for this week...\n\n"

  instahours.entries_for.each do | entry |
    puts ">> #{entry["date"]} | #{entry["project-name"]} >> #{entry["hours"]}h #{entry["minutes"]} "
  end

  puts "\nYou have logged #{instahours.time_for_in_hours} hours so far for the week.\n\n"

  complete = ask( "Do you want to fill in the remaining time for this week? (y/n)") { | q | }

  if complete == 'y'
    instahours.complete

    puts "\nCool beans! All Done.\n"
    puts "Here is how your week looks now...\n"

    instahours.entries_for.each do | entry |
      puts ">> #{entry["date"]} | #{entry["project-name"]} >> #{entry["hours"]}h #{entry["minutes"]} "
    end

    puts "\nYou have logged #{instahours.time_for_in_hours} hours so far for the week.\n\n"

    puts "\n\nBye-bye\n\n\n"

  else
    puts "Alrighty then. You can always do this later."
  end


else
  puts "well you need to fix for env variables then"
end
