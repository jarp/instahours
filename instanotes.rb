require 'net/http'
require 'openssl'
require 'json'
require 'date'
require 'yaml'

class InstaNotes

  def initialize(date=nil, options={})
    raise "Credentials are missing from ENV variables. Must set 'TW_API_KEY', 'TW_USER_ID' and 'TW_PROJECT_ID'" if ENV['TW_API_KEY'].empty? ||  ENV['TW_USER_ID'].empty? || ENV['TW_PROJECT_ID'].empty?
    @options = {
        api: ENV['TW_API_KEY'],
        company: 'notredame',
        user_id: ENV['TW_USER_ID'],
        project_id: ENV['TW_PROJECT_ID']
      	}
    @tw_uri = "https://#{@options[:company]}.teamworkpm.net"
  end


  def fetch_lists
  	uri = URI("#{@tw_uri}/projects/#{@options[:project_id]}/tasklists.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["tasklists"]
  end

  def current_list
  	fetch_lists.first
  end

  def fetch_completed_tasks
	uri = URI("#{@tw_uri}/tasklists/#{current_list["id"]}/tasks.json?filter=completed")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options[:api], 'pass'
    response = http.request(request)
    return JSON.parse(response.body)["todo-items"]
  end

  def notes

  	notes = ["#{current_list["name"]} Notes"]
  	notes << '################################'
  	tasks = fetch_completed_tasks
  	tasks.each do | task |
  		notes << task_to_notes(task)
  	end
  	return notes
  end

  def task_to_notes(task)
  	note = task["content"]
  end

end
