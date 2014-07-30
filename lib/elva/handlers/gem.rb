module Elva
  module Handlers
    class Gem < Base
      attr_reader :gem_name

      def match?
        _, @gem_name = *content.to_s.match(/\A!gem +(.*?)\z/)
        gem_name
      end

      def process
        response = Aitch.get(api_url)

        if response.ok?
          options = response.data.each_with_object({}) do |(key, value), buffer|
            buffer[key.to_sym] = value
          end

          broadcast t('rubygems_details', options)
        else
          broadcast t('rubygems_search', name: gem_name, url: search_url)
        end
      end

      def api_url
        "https://rubygems.org/api/v1/gems/%s.json" % CGI.escape(gem_name)
      end

      def search_url
        'https://rubygems.org/search?query=%s' % CGI.escape(gem_name)
      end
    end
  end
end
