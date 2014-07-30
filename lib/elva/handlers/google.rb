module Elva
  module Handlers
    class Google < Base
      attr_reader :term

      def match?
        _, @term = *content.to_s.match(/\A!google (.*?)\z/)
        term
      end

      def process
        broadcast 'https://google.com/search?q=%s' % CGI.escape(term)
      end
    end
  end
end
