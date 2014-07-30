module Elva
  module Handlers
    class Npm < Base
      attr_reader :package

      def match?
        _, @package = *content.to_s.match(/\A!npm +(.*?)\z/)
        package
      end

      def process
        response = Aitch.get(api_url)

        if response.ok?
          options = response.data.each_with_object({}) do |(key, value), buffer|
            buffer[key.to_sym] = value
          end

          options[:project_uri] = project_url

          broadcast t('npm_details', options)
        else
          broadcast t('npm_search', name: package, url: search_url)
        end
      end

      def project_url
        "http://npmjs.org/%s" % CGI.escape(package)
      end

      def api_url
        "http://registry.npmjs.org/%s" % CGI.escape(package)
      end

      def search_url
        'https://www.npmjs.org/search?q=%s' % CGI.escape(package)
      end
    end
  end
end
