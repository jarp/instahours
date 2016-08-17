class InstaCommits < Insta

  def fetch_commits
    from_date = formatted_date(start_date + 1, "-")
    to_date = formatted_date(start_date + 5, "-")
    commits = []

    fetch_branches.each do | branch |
      uri = URI("https://api.github.com/repos/ndwebgroup/conductor/commits?since=#{from_date}&till=#{to_date}&author=#{@options['github_user']}&sha=#{branch}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth @options['github_user'], @options['github_password']
      response = http.request(request)
      entries = JSON.parse(response.body)

      entries.each_with_index do | entry, i |
        commits << entry_to_text(branch, entry, i + 1)
      end
    end
    # puts time.inspect
    return commits
  end


  def fetch_branches
    uri = URI("https://api.github.com/repos/ndwebgroup/conductor/branches")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth @options['github_user'], @options['github_password']
    response = http.request(request)
    branch_data = JSON.parse(response.body)
    branches = []

    branch_data.each do | b |
      branches << b["name"]
    end
    # puts time.inspect
    return branches
  end

  def entry_to_text(branch, entry, i)
    return "\nCOMMIT ##{i}: #{branch} \n#{entry["commit"]["committer"]["date"]}\n#{entry["commit"]["message"]}\n"
  end

end
