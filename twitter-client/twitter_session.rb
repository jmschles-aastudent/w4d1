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

    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)
    begin
      puts "Login, and type your verification code in"
      oauth_verifier = gets.chomp
      access_token = request_token.get_access_token(
          :oauth_verifier => oauth_verifier)
    rescue
      puts "Wrong code"
      retry
    end
    access_token
  end

  def set_token(username)
    token_file = "tokens/#{username}.yml"
    if File.exist?(token_file)
      @access_token = File.open(token_file) { |f| YAML.load(f) }
    else
      @access_token = request_access_token
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }
      access_token
    end
  end

end

if __FILE__ == $0
  token_file = "token.yml"
  session = TwitterSession.new
  session.set_token(token_file)
  tweets = session.tweets
  p tweets
end
