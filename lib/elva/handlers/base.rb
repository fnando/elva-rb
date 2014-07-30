module Elva
  module Handlers
    def self.available_handlers
      @available_handlers ||= []
    end

    class Base
      attr_reader :socket, :message, :nickname, :sender, :channel, :content

      def self.inherited(child)
        Handlers.available_handlers << child
      end

      def initialize(socket, nickname, message)
        @socket = socket
        @message = message
        @nickname = nickname
        _, @sender, @channel, @content = *message.match(/\A:([^!]+)!.*? PRIVMSG #([^ ]+) :(.*?)\z/)
      end

      def active?
        true
      end

      def match?
        false
      end

      def process
        # noop
      end

      def say(message)
        debug message
        socket.puts message
      end

      def broadcast(message)
        say "PRIVMSG ##{channel} :#{message}"
      end

      def t(scope, options = {})
        I18n.t(scope, options)
      end

      def debug(message)
        $stdout << message << "\n" if $DEBUG
      end

      def names
        @names ||= begin
          say "NAMES ##{channel}"
          response = socket.gets.chomp
          regex = /\A:.*? #{Regexp.escape(nickname)} @ ##{Regexp.escape(channel)} :(.*?)\z/
          response[regex, 1].split(' ')
        end
      end
    end
  end
end
