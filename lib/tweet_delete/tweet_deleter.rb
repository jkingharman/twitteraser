module TweetDelete
  # A class for requesting Twitter to destroy specified tweets.
  class TweetDeleter
    def initialize
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['CONSUMER_KEY']
        config.consumer_secret     = ENV['CONSUMER_SECRET']
        config.access_token        = ENV['ACCESS_TOKEN']
        config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
      end
      @retries = 0
    end

    def call(id)
      client.destroy_status(id)
    rescue Twitter::Error::NotFound => e
      puts "Tweet #{id} not found"
    rescue HTTP::ConnectionError => e
      abort 'Connection error. Restart the process'
    rescue Twitter::Error::TooManyRequests => e
      puts 'Rate limit exceeded.'
      sleep e.rate_limit.reset_in + 1
      increase_retry_count
      retry
    end

    private

    attr_reader :client, :retries

    def increase_retry_count
      @retries += 1
      abort 'At risk of blacklisting' if retries == 4
    end
  end
end
