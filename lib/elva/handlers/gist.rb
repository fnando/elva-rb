module Elva
  module Handlers
    class Gist < Base
      def match?
        content && content.match(/\A!gist/)
      end

      def process
        broadcast t('use_gist')
      end
    end
  end
end
