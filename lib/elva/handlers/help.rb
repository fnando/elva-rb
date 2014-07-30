module Elva
  module Handlers
    class Help < Base
      def match?
        content.to_s.match(/\A!help/)
      end

      def process
        broadcast 'http://github.com/fnando/elva-rb'
      end
    end
  end
end
