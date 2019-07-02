def initialize(date=nil, options={})
    load_config
    raise "Credentials are missing from ENV variables. Must set 'TW_API_KEY', 'TW_USER_ID' and 'TW_PROJECT_ID'" if ENV['TW_API_KEY'].empty? ||  ENV['TW_USER_ID'].empty? || ENV['TW_PROJECT_ID'].empty?
    @options = {
        'api' => ENV['TW_API_KEY'],
        'user_id' => ENV['TW_USER_ID'],
        'github_password' => ENV['GITHUB_PWD']
      }.merge(load_config).merge(options)
    @tw_uri = "https://#{@options['company']}.teamworkpm.net"
    @date = date.nil? ? Date.today : date
  end


  def default_project
    uri = URI("#{@tw_uri}/projects/#{@options['project_id']}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options['api'], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["project"]["name"]
  end



  def default_person
    uri = URI("#{@tw_uri}/people/#{@options['user_id']}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options['api'], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["person"]["first-name"]
  end


 def start_date
    # subtract on cuz TW seems to not include first day when getting aggregate time data
    monday = @date - days_since_monday - 1
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


  def remaining_time(date)
    total_time = time_for(date)
    480 - total_time.to_i
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

