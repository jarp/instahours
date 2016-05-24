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
    @active_task_list_id = current_list["id"]
  end

  def current_list
    fetch_lists.first
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

  
  # REMOTE API CALLS  
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

    def fetch_completed_tasks(id=nil)
      list_id = id.nil? ? current_list["id"] : id
    	uri = URI("#{@tw_uri}/tasklists/#{list_id}/tasks.json?filter=completed")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth @options[:api], 'pass'
        response = http.request(request)
      return JSON.parse(response.body)["todo-items"]
    end

    def fetch_open_tasks(id=nil)
      list_id = id.nil? ? current_list["id"] : id
      uri = URI("#{@tw_uri}/tasklists/#{list_id}/tasks.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth @options[:api], 'pass'
        response = http.request(request)
      return JSON.parse(response.body)["todo-items"]
    end

    def new_list    
      remaining_tasks = fetch_open_tasks
      new_date = date_from_list + 7
      list =
        {
        "todo-list" => {
          "name" => "v#{new_date.strftime('%Y-%m-%d')} Deploy",
          "private" => false,
          "pinned" => true,
          "milestone-id" => "",
          "description" => "Nutter Set of changes",
          "addToTop" => true
          }
        }

      uri = URI("#{@tw_uri}/projects/#{@options[:project_id]}/tasklists.json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.basic_auth @options[:api], 'pass'
      request.body = list.to_json
      response = http.request(request)

      new_list_id = current_list["id"]

      remaining_tasks.each do | task |
        puts "moving task #{task} to new list"
        update_task(task["id"], new_list_id)
      end

      archive_list
    end


    def archive_list
     list =
      {
      "todo-list" => {
        "completed" => true
        }
      }

       uri = URI("#{@tw_uri}/tasklists/#{@active_task_list_id}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Put.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
        request.basic_auth @options[:api], 'pass'
        request.body = list.to_json
        response = http.request(request)

    end

    def update_task(id, new_list_id)
      task = {
        "todo-item" => { "tasklistId" => new_list_id }
      }

      uri = URI("#{@tw_uri}/tasks/#{id}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Put.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
        request.basic_auth @options[:api], 'pass'
        request.body = task.to_json
        response = http.request(request)
    end


  # SUPPORT TRANSFORMATIONS

  def task_to_notes(task)
  	note = task["content"]
  end

  def date_from_list
    date = current_list["name"].gsub!('v', '')
    date.gsub(' Deploy', '')
    Date.parse(date)
  end
end
