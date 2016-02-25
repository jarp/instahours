require 'net/http'
require 'openssl'
require 'json'
require 'date'
require 'yaml'

class InstaHours
  def load_projects
    begin
      YAML.load_file('projects.yml')
    rescue => e
      puts "can't load yaml project file"
      return {}
    end
  end

  def initialize(date=nil, options={})
    load_projects
    raise "Credentials are missing from ENV variables. Must set 'TW_API_KEY', 'TW_USER_ID' and 'TW_PROJECT_ID'" if ENV['TW_API_KEY'].empty? ||  ENV['TW_USER_ID'].empty? || ENV['TW_PROJECT_ID'].empty?
    @options = {
        api: ENV['TW_API_KEY'],
        company: 'notredame',
        user_id: ENV['TW_USER_ID'],
        project_id: ENV['TW_PROJECT_ID']
      }.merge(load_projects).merge(options)
    @tw_uri = "https://#{@options[:company]}.teamworkpm.net"
    @date = date.nil? ? Date.today : date
  end

  def complete
    #start date is actually a day before week starts so add 1
    1.upto(5).each do | d |
      check_date = start_date + d
      add_time = remaining_time(check_date)
      puts "checking date #{check_date}"
      if remaining_time(check_date) > 0 && check_date <= Date.today
        puts "adding #{add_time} minutes for date of #{check_date}"
        result = add_time(add_time, check_date)
      end
    end
  end

  def default_project
    uri = URI("#{@tw_uri}/projects/#{@options[:project_id]}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["project"]["name"]
  end

  def favorite_projects
    return @options['projects'] if @options['projects']
    return []
  end

  def default_person
    uri = URI("#{@tw_uri}/people/#{@options[:user_id]}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["person"]["first-name"]
  end


  def add_time(amount, date, project_id=nil)
    puts "[debug] adding time for #{project_id}"
    entry_project_id = project_id.nil? ? @options[:project_id] : project_id
    puts "[debug] still adding time for #{project_id}"
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

    uri = URI("#{@tw_uri}/projects/#{entry_project_id}/time_entries.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.basic_auth @options[:api], 'pass'
    request.body = entry.to_json
    response = http.request(request)
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
      uri_time = "/time_entries.json?userId=#{@options[:user_id]}&fromdate=#{formated_date(start_date)}&todate=#{formated_date(end_date)}"
    end

    uri = URI("#{@tw_uri}#{uri_time}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    begin
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth @options[:api], 'pass'
      response = http.request(request)
      entries = JSON.parse(response.body)["time-entries"]
      return [] if entries.nil?
      entries.each { | e | e["date"] = Date.parse(e["date"]).strftime('%D') }

    rescue => e
      puts "!!!!!!! Error: #{e}"
    end
  end

  def company
    @options[:company]
  end

  private

  def start_date
    # subtract on cuz TW seems to not include first day when getting aggregate time data
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
