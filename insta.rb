require 'net/http'
require 'openssl'
require 'json'
require 'date'
require 'yaml'

class Insta
  def load_config
    begin
      YAML.load_file('config.yml')
    rescue => e
      puts "can't load yaml config file"
      return {}
    end
  end

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

  def favorite_projects
    return @options['projects'] if @options['projects']
    return []
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

  def company
    @options[:company]
  end

  private

  def start_date
    # subtract on cuz TW seems to not include first day when getting aggregate time data
    monday = @date - days_since_monday - 1
  end

  def formatted_date(date,delimiter="")
    DateTime.new(date.year, date.month, date.day).strftime("%Y#{delimiter}%m#{delimiter}%d")
  end

  def end_date
    monday = start_date
    friday = monday + 5
  end

  def days_since_monday
    @date.wday - 1
  end
end
