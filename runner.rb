require_relative 'instahours'
require 'highline/import'
require 'date'

class Runner
  def initialize
    system 'clear'
    @instahours = ::InstaHours.new
    @project = @instahours.default_project
  end

  def confirm
    puts "TeamWork @instahours\n==========================================\n\n"
    puts "Hi there #{@instahours.default_person}. Your default project seems to be '#{@project}'."
    continue = ask("Is your name and project correct? ({enter}/n)") { |q| }
    unless continue == 'n'
      puts "\nAwesome!\n\n"
    else
      raise "\nWell.. you need to fix that then. Set your ENV variables."
    end
  end

  def set_date
    which_date = ask("What week do you want to work with? Enter any date within the week (yyyy/mm/dd format). Just leave blank if you want to work with the current one.")
    unless which_date.empty?
        new_date = Date.parse(which_date)
        @instahours = InstaHours.new(new_date)
      begin
      rescue => e
        puts "Alright changed week from current week to the week of #{which_date}"
        puts "You are an idiot and '#{which_date}' is not a date. So let's just work with the current week then. Get smarter and enter a correct date next time."
        puts "e: #{e}"
      end
    end
  end

  def show_entries
    puts "Here are your time entries for the week...\n\n"
    current_entires = @instahours.entries_for
    current_entires.each do | entry |
      puts ">> #{entry["date"]} | #{entry["project-name"]} | #{entry["hours"]}h #{entry["minutes"]}m"
    end

    puts "........" if current_entires.empty?
    puts "\nYou have logged #{@instahours.time_for_in_hours} hours so far for the week.\n\n"
  end

  def get_date_from_array(entry_array)
    begin
      return Date.parse(entry_array[2])
    rescue
      return Date.today
    end
  end

  def get_note_from_array(entry_array)
    begin
      Date.parse(entry_array[2]).strftime('%D')
      return entry_array[3] if entry_array.length == 4
    rescue
      return entry_array[2] if entry_array.length == 3
    end
    return "" if entry_array.length == 2
  end

  def add_hours
    add_hours = ask("Do you want to add an entry for a project? (y/{enter})")
    if add_hours == 'y'
      puts "Looks like you have  #{@instahours.favorite_projects.count} projects \n\n"
      @instahours.favorite_projects.each_key do  | project |
        puts ">> #{project}"
      end

      new_entry = ask("Add your entry in the format of 'project|hours|date|note'. Leave date blank if you want to use the current date. The last item can be a note.")
      begin
        entry_array = new_entry.split('|')
        entry = {
            project_id: @instahours.favorite_projects[entry_array[0]],
            minutes: (entry_array[1].to_f * 60).round,
            date: get_date_from_array(entry_array),
            note: get_note_from_array(entry_array)
          }

        raise 'You tried to add hours to a non-existent project' unless @instahours.favorite_projects.fetch(entry_array[0], nil)
        @instahours.add_time(entry[:minutes], entry[:date], entry[:project_id], entry[:note])
      rescue => e
        puts "Can't format entry:: #{e}"
      end
    end
    return add_hours
  end

  def complete

    complete = ask( "Do you want to fill in the remaining time for this week? (y/{enter})") { | q | }

    if complete == 'y'
      @instahours.complete

      puts "\nCool beans! All Done.\n"
      puts "Here is how your week looks now...\n"

      @instahours.entries_for.each do | entry |
        puts ">> #{entry["date"]} | #{entry["project-name"]} | #{entry["hours"]}h #{entry["minutes"]}m"
      end

      puts "\nYou have logged #{@instahours.time_for_in_hours} hours so far for the week.\n\n"

    else
      puts "\nAlrighty then. You can always do this later.\n\n"
    end
  end

  def go_to_web
    browse = ask("Do you want to go to the Teamwork website now? (y/{enter})") { | q | }

    if browse == "y"
      system "/usr/bin/open -a '/Applications/Google Chrome.app' 'https://#{@instahours.company}.teamworkpm.net/all_time'"
    end

    puts "\n\nBye-bye\n\n\n"
  end
end
