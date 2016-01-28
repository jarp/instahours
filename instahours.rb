# Teamwork::InstaHours
# allows you to see time entries and total hours for a given week
# allows you to generate all missing time and apply it to a given default project
# Requirements:
# => enable TW api key in your account
# => set 3 Env variables on your puter: TW_API_KEY, TW_USER_ID, TW_PROJECT_ID
# => include this class in a script

  # EXAMPLE
    # require_relative 'instahours'
    #
    # instahours = InstaHours.new
    ##  or instahours = InstaHours.new(Date.new(2016,01,28))
    # entries = instahours.entries_for
    # time = instahours.time_for_in_hours
    #
    # puts "Total time logged is  #{time} "
    # puts "There are #{entries.count} time entries"
    #
    # entries.each do | entry |
    #   puts "#{entry["date"]} | #{entry["project-name"]} >> #{entry["hours"]}h #{entry["minutes"]}m "
    # end
    #
    # instahours.complete

require 'net/http'
require 'openssl'
require 'json'
require 'date'

class InstaHours
  def initialize(date=nil, options={})
    raise "Credentials are missing from ENV variables" if ENV['TW_API_KEY'].empty? || ENV['TW_USER_ID'].empty? || ENV['TW_PROJECT_ID'].empty?
    @options = {
        api: ENV['TW_API_KEY'],
        company: 'notredame',
        user_id: ENV['TW_USER_ID'],
        project_id: ENV['TW_PROJECT_ID']
      }.merge(options)

    @tw_uri = "https://#{@options[:company]}.teamworkpm.net"
    @date = date.nil? ? Date.today : date
  end

  def complete
    1.upto(5).each do | d |
      check_date = start_date + d
      add_time = remaining_time(check_date)
      if remaining_time(check_date) > 0
        puts "adding #{add_time} minutes for date of #{check_date}"
        result = add_time(add_time, check_date)
      end
    end
  end

  def add_time(amount, date)
    entry =
    {
      "time-entry" => {
        "description" => "",
        "person-id" => @options[:user_id],
        "date" => formated_date(date),
        "time" => "08:00",
        "hours" => "0",
        "minutes" => amount,
        "isbillable" => "0",
        "tags" => ""
      }
    }

    uri = URI("#{@tw_uri}/projects/#{@options[:project_id]}/time_entries.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.basic_auth @options[:api], 'pass'
    request.body = entry.to_json
    res = http.request(request)
  end

  def time_for_in_hours(day=nil)
    time_for(day).to_i / 60
  end

  def time_for(day=nil)
    if day
      uri_time = "/time/total.json?userId=#{@options[:user_id]}&fromdate=#{formated_date(day)}&todate=#{formated_date(day)}"
    else
      uri_time = "/time/total.json?userId=#{@options[:user_id]}&fromdate=#{formated_date(start_date)}&todate=#{formated_date(end_date)}"
    end
    uri = URI("#{@tw_uri}#{uri_time}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    res = http.request(request)
    return JSON.parse(res.body)["time-totals"]["total-mins-sum"]
  end

  def entries_for(day=nil)
    if day
      uri_time = "/time_entries.json?userId=#{@options[:user_id]}&fromdate=#{formated_date(day)}&todate=#{formated_date(day)}"
    else
      uri_time = "/time_entries.json?userId=95087&fromdate=#{formated_date(start_date)}&todate=#{formated_date(end_date)}"
    end

    uri = URI("#{@tw_uri}#{uri_time}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    res = http.request(request)
    return JSON.parse(res.body)["time-entries"]
  end

  private

  def start_date
    monday = @date - days_since_monday - 1
  end

  def formated_date(date)
    DateTime.new(date.year, date.month, date.day).strftime('%Y%m%d')
  end

  def end_date
    monday = start_date
    friday = monday + 5
  end

  def days_since_monday
    @date.wday - 1
  end

  def remaining_time(date)
    total_time = time_for(date)
    480 - total_time.to_i
  end

  def has_entry?(entries, date)
    entries.each do | entry |
      return true if Date.parse(entry["date"]).strftime('%D') == date.strftime('%D')
    end

    return false
  end

end
