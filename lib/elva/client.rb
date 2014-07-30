module Elva
  class Client
    attr_reader :channels, :nickname, :password

    def initialize(channels, nickname, password)
      @channels = channels
      @nickname = nickname
      @password = password
    end

    def run
      connect!

      process(socket.gets) until socket.eof?
    end

    private

    def connect!
      socket.gets
      say "NICK #{nickname}"

      socket.gets
      say "USER #{nickname} 0 * #{nickname.capitalize}"

      socket.gets
      say "PRIVMSG NickServ :IDENTIFY #{password}"

      channels.each do |channel|
        socket.gets
        say "JOIN ##{channel}"
        socket.gets
      end
    end

    def say(message)
      debug message
      socket.puts message
    end

    def socket
      @socket ||= TCPSocket.open('irc.freenode.net', '6667')
    end

    def process(message)
      message = message.chomp
      debug message

      Handlers.available_handlers.each do |handler_class|
        handler = handler_class.new(socket, nickname, message)
        handler.process if handler.active? && handler.match?
      end
    rescue Exception => error
      logger.error error.message
      logger.error error.backtrace.join(?\n)
    end

    def logger
      @logger ||= Logger.new($stdout)
    end

    def debug(message)
      $stdout << message << ?\n if $DEBUG
    end
  end
end
