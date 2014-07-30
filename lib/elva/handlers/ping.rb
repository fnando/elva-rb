module Elva
  module Handlers
    class Ping < Base
      attr_reader :host

      def match?
        _, @host = *message.match(/\APING :(.*?)\z/)
        @host
      end

      def process
        say "PONG #{host}"
      end
    end
  end
end
