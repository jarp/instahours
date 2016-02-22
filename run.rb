#!/usr/bin/env ruby
require 'highline/import'
require_relative 'instahours'
require 'date'

instahours = InstaHours.new
project = instahours.default_project

system 'clear'

puts "TeamWork InstaHours\n==========================================\n\n"
puts "Hi there #{instahours.default_person}. Your default project seems to be '#{project}'."

continue = ask("Is your name and project correct? (y/n)") { |q| }


unless continue == 'n'

  puts "\nAwesome!\n\n"


which_date = ask("What week do you want to work with? Enter any date within the week (yyyy/mm/dd format). Just leave blank if you want to work with the current one.")

unless which_date.empty?
  begin
    new_date = Date.parse(which_date)
    instahours = InstaHours.new(new_date)
    puts "Alright changed week from current week to the week of #{which_date}"
  rescue => e
    puts "You are an idiot and '#{which_date}' is not a date. So let's just work with the current week then. Get smarter and enter a correct date next time."
  end
end


  puts "Here are your time entries for the week...\n\n"
  current_entires = instahours.entries_for
  current_entires.each do | entry |
    puts ">> #{entry["date"]} | #{entry["project-name"]} | #{entry["hours"]}h #{entry["minutes"]}m"
  end

  puts ">>........" if current_entires.empty?

  puts "\nYou have logged #{instahours.time_for_in_hours} hours so far for the week.\n\n"

  # add_hours = ask("Do you want to add an entry for a project?")
  #
  # if add_hours
  #   puts "Looks like you have  #{instahours.favorite_projects.count} projects"
  #   instahours.favorite_projects.each_key do  | project |
  #     puts ">> #{project}"
  #   end
  #
  #   puts "add hours by entering 'Project|hours|date (yyyy/mm/dd)'. Date is optional."
  #   new_entry = ask("Entry?")
  #
  #   begin
  #     entry_array = new_entry.split('|')
  #     #puts "mulyi #{entry_array[1]} * 60 == #{(entry_array[1] * 60).round}"
  #     entry = {project_id: instahours.favorite_projects[entry_array[0]], minutes: (entry_array[1].to_f * 60).round, date: Date.today}
  #     puts "#{entry_array} is a class of #{entry_array.class}"
  #     entry[:date] = entry_array[2] if entry_array.length == 3
  #     puts "entry will be #{entry}"
  #   rescue => e
  #     puts "Can't format entry:: #{e}"
  #   end
  # end

  complete = ask( "Do you want to fill in the remaining time for this week? (y/n)") { | q | }

  if complete == 'y'
    instahours.complete

    puts "\nCool beans! All Done.\n"
    puts "Here is how your week looks now...\n"

    instahours.entries_for.each do | entry |
      puts ">> #{entry["date"]} | #{entry["project-name"]} | #{entry["hours"]}h #{entry["minutes"]}m"
    end

    puts "\nYou have logged #{instahours.time_for_in_hours} hours so far for the week.\n\n"

  else
    puts "\nAlrighty then. You can always do this later.\n\n"
  end

  browse = ask("Do you want to go to the Teamwork website now? (y/n)") { | q | }

  if browse == "y"
    system "/usr/bin/open -a '/Applications/Google Chrome.app' 'https://#{instahours.company}.teamworkpm.net/all_time'"
  end

  puts "\n\nBye-bye\n\n\n"


else
  puts "\nWell.. you need to fix that then. Set your ENV variables."
end
