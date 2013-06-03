require 'launchy'
require 'oauth'
require 'yaml'
require 'json'
require 'rest-client'

# "consumer" in OAuth terminology means "client" in our discussion.


class TwitterSession
  CONSUMER_KEY = "iEF943evwJMAHlTsfaf1ew"
  CONSUMER_SECRET = "6k7kA6mqBrCqkc5i6bvuzONdBEtuhErssENw7FnXXbw"
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  attr_reader :access_token

  def initialize
    @access_token = nil
  end

  def request_access_token
    return access_token if access_token

    # access_token = access_token_from_file("token")
   #  return access_token if access_token

    # send user to twitter URL to authorize application
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)
    begin
      # because we don't use a redirect URL; user will receive an "out of
      # band" verification code that the application may exchange for a
      # key; ask user to give it to us
      puts "Login, and type your verification code in"
      oauth_verifier = gets.chomp

      # ask the oauth library to give us an access token, which will allow
      # us to make requests on behalf of this user
      access_token = request_token.get_access_token(
          :oauth_verifier => oauth_verifier)
    rescue
      puts "Wrong code"
      retry
    end
    # File.open("token", 'w') {|f| f.write(access_token) }
    # @access_token = access_token
    access_token
  end

  # fetch a user's timeline
  def user_timeline #(access_token)
    url = Addressable::URI.new(
       :scheme => "http",
       :host => "api.twitter.com",
       :path => "1.1/statuses/user_timeline.json"
       ).to_s

    raw_json = access_token.get(url).body
    json = JSON.parse(raw_json)
    json
  end

  def tweets
    timeline = user_timeline
    tweets = []
    # timeline = session.user_timeline
    timeline.each do |tweet|
      tweets << tweet["text"]
    end
    tweets
  end

  def set_token(token_file)
    # We can serialize token to a file, so that future requests don't need
    # to be reauthorized.

    if File.exist?(token_file)
      @access_token = File.open(token_file) { |f| YAML.load(f) }
    else
      @access_token = request_access_token
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }
      access_token
    end
  end

end

token_file = "token.yml"
session = TwitterSession.new
session.set_token(token_file)
tweets = session.tweets
p tweets