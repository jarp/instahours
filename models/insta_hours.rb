require_relative 'insta'

class InstaHours < Insta

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

  def add_time(amount, date, project_id=nil, note="")
    entry_project_id = project_id.nil? ? @options["project_id"] : project_id
    entry =
    {
      "time-entry" => {
        "person-id" => @options['user_id'],
        "date" => formatted_date(date),
        "time" => "08:00",
        "hours" => "0",
        "minutes" => amount,
        "isbillable" => "1",
        "description" => note,
        "tags" => ""
      }
    }

    uri = URI("#{@tw_uri}/projects/#{entry_project_id}/time_entries.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.basic_auth @options['api'], 'pass'
    request.body = entry.to_json
    response = http.request(request)
  end

  def time_for_in_hours(day=nil)
    time_for(day).to_i / 60
  end

  def time_for(day=nil)
    if day
      uri_time = "/time/total.json?userId=#{@options['user_id']}&fromdate=#{formatted_date(day)}&todate=#{formatted_date(day)}"
    else
      uri_time = "/time/total.json?userId=#{@options['user_id']}&fromdate=#{formatted_date(start_date)}&todate=#{formatted_date(end_date)}"
    end
    uri = URI("#{@tw_uri}#{uri_time}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options['api'], 'pass'
    res = http.request(request)
    return JSON.parse(res.body)["time-totals"]["total-mins-sum"]
  end

  def entries_for(day=nil)
    if day
      uri_time = "/time_entries.json?userId=#{@options['user_id']}&fromdate=#{formatted_date(day)}&todate=#{formatted_date(day)}"
    else
      uri_time = "/time_entries.json?userId=#{@options['user_id']}&fromdate=#{formatted_date(start_date)}&todate=#{formatted_date(end_date)}"
    end

    uri = URI("#{@tw_uri}#{uri_time}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    begin
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth @options['api'], 'pass'
      response = http.request(request)
      entries = JSON.parse(response.body)["time-entries"]
      return [] if entries.nil?
      entries.each { | e | e["date"] = Date.parse(e["date"]).strftime('%D') }

    rescue => e
      puts "!!!!!!! Error: #{e}"
    end
  end

  private

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
