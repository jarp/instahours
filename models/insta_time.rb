require_relative 'insta'
require 'net/http'
require 'openssl'
require 'json'
require 'date'
require 'yaml'

class InstaTime < Insta

  def fetch_time()
    from_date = formatted_date(start_date + 1)
    to_date = formatted_date(start_date + 5)
    uri = URI("#{@tw_uri}/time_entries.json?fromdate=#{from_date}&todate=#{to_date}&userid=#{@options['user_id']}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options['api'], 'pass'
    response = http.request(request)
    entries = JSON.parse(response.body)["time-entries"]

    time = []
    entries.sort_by { | e | e["todo-item-name"]}.each do | entry |
      time << time_to_text(entry)
    end
    return time
  end

  def time_to_text(entry)
    text = "> #{entry["project-name"]}:#{entry["todo-item-name"]}"
    text = "#{text}\n> '#{entry["description"]}'" unless entry["description"].empty?
    text = "#{text}\n>  #{entry["hours"]} hours #{entry["minutes"]} minutes \n\n"
  end
end
