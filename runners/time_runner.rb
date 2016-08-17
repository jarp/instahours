require_relative '../models/insta_time'
require_relative '../models/insta_commits'
require 'highline/import'
require 'date'

class TimeRunner
  def initialize
    system 'clear'
    @instatime = ::InstaTime.new
    @instacommits = ::InstaCommits.new
    @project = @instatime.default_project
  end

  def confirm
    puts "TeamWork @instatime\n=========================================\n\n"
    puts "Hi there #{@instatime.default_person}. Your default project seems to be '#{@project}'."
    continue = ask("Is your name and project correct? ({enter}/n)") { |q| }
    unless continue == 'n'
      puts "\nAwesome!\n\n"
    else
      raise "\nWell.. you need to fix that then. Set your ENV variables."
    end
  end

  def set_date
    which_date = ask("What week do you want to work with? Enter any date within the week ('mm/dd' or 'yyyy/mm/dd' format). Just leave blank if you want to work with the current one.")
    unless which_date.empty?
        new_date = determine_date(which_date)
        puts "Alright changed week from current week to the week of #{new_date}"
        @instatime = InstaTime.new(new_date)
        @instacommits = InstaCommits.new(new_date)
      begin
      rescue => e
        puts "You are an idiot and '#{which_date}' is not a date. So let's just work with the current week then. Get smarter and enter a correct date next time."
        puts "e: #{e}"
      end
    end
  end

  def list_time
    time = @instatime.fetch_time
    puts "You logged time for the following tasks during the week\n\n"
    time.each do | t |
      puts "#{t}"
    end
    puts "\n"
  end

  def list_commits
    commits = @instacommits.fetch_commits
    puts "You made the following commits\n\n"
    commits.each do | t |
      puts "#{t}"
    end
    puts "\n"
  end

  def go_to_web
    browse = ask("Do you want to go to the Teamwork website now? (y/{enter})") { | q | }

    if browse == "y"
      system "/usr/bin/open -a '/Applications/Google Chrome.app' 'https://#{@instatime.company}.teamworkpm.net/all_time'"
    end

    puts "\n\nBye-bye\n\n\n"
  end

  private

  def determine_date(date)
    return Date.parse("#{DateTime.now.year}/#{date}") if date.split('/').count ==2
    return Date.parse("#{DateTime.now.year}-#{date}") if date.split('-').count ==2
    return Date.parse(date)
  end
end
