require_relative 'twitter_session'
require 'addressable/uri'

class User
  attr_reader :username, :session

  def initialize(username)
    @username = username
    @session = nil
    # @access_token = nil
  end

  def set_access_token
    @session = TwitterSession.new
    session.set_token(username)
    puts "access token set: #{session.access_token}"
  end

  def check_access_token
    url = Addressable::URI.new(
       :scheme => "http",
       :host => "api.twitter.com",
       :path => "1/account/verify_credentials.json"
       ).to_s

    session.access_token.get(url).response.code
  end

  # fetch a user's timeline
  def timeline #(access_token)
    url = Addressable::URI.new(
       :scheme => "http",
       :host => "api.twitter.com",
       :path => "1.1/statuses/user_timeline.json"
       ).to_s

    raw_json = session.access_token.get(url).body
    json = JSON.parse(raw_json)
    json
  end

  def tweets
    tweets = []
    timeline.each do |tweet|
      tweets << tweet["text"]
    end
    tweets
  end

  def followers_ids(for_username = username)
    url = Addressable::URI.new(
    :scheme => "https",
    :host => "api.twitter.com",
    :path => "1.1/followers/ids.json",
    :query_values => {
      :screen_name => for_username,
      :count => 5000
      }).to_s

    raw_json = session.access_token.get(url).body
    json = JSON.parse(raw_json)
    json
  end

  def followers_list(for_username = username)
    followers_list = []
    cursor = -1
    until cursor.zero?
      url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/followers/list.json",
      :query_values => {
        :screen_name => for_username,
        :skip_status => true,
        :include_user_entities => false,
        :cursor => cursor
      }).to_s

      # puts session.access_token
      # p session.access_token.get(url).header
      # break
      raw_json = session.access_token.get(url).body
      json = JSON.parse(raw_json)

      puts cursor
      # puts json
      users = json["users"]
      users.each do |user|
        followers_list << user["screen_name"]
      end

      cursor = json["next_cursor"]
    end
    followers_list
  end

  def followers_usernames(for_username = username)
    json = followers_list(for_username)
    users = json["users"]
    usernames = []
    users.each do |user|
      usernames << user["screen_name"]
    end
    usernames
  end

  def get_and_post
    print "Input your tweet: "
    status_text = gets.chomp
    post(status_text)
  end

  def post(status)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/statuses/update.json",
      :query_values => {
        :status => status
        }).to_s

    response = session.access_token.post(url)
    p response.response.code
  end

end

sean = User.new("seanomlor")
sean.set_access_token
puts sean.check_access_token
p sean.followers_list
# p sean.followers_list
# sean.follower_names
sean.get_and_post
