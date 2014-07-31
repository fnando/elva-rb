module Elva
  module Handlers
    class Tweet < Base
      attr_reader :tweet_id

      def match?
        _, @tweet_id = *message.match(%r[https://twitter.com/[^/]+/status/(\d+)])
        @tweet_id
      end

      def process
        response = Aitch.get(tweet_url)

        if response.ok?
          html = Nokogiri::HTML(response.data['html'])
          broadcast html.text().chomp
        elsif response.not_found?
          broadcast t('tweet.not_found')
        end
      end

      def tweet_url
        "https://api.twitter.com/1/statuses/oembed.json?id=#{tweet_id}"
      end
    end
  end
end
