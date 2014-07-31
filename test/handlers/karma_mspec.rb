require 'minitest/autorun'
require 'mocha/mini_test'
require 'i18n'
require 'fileutils'

require './lib/elva/handlers/base'
require './lib/elva/handlers/karma'

ENV['KARMA_PSTORE_URI'] ||= '/tmp/elva.pstore'
I18n.load_path = Dir[File.expand_path('../../../locales/pt-BR.yml', __FILE__)]
I18n.default_locale = 'pt-BR'

describe 'Karma' do
  def msg(content, channel: 'devbr', sender: 'john')
    ":#{sender}! PRIVMSG ##{channel} :#{content}"
  end

  def handle_message(content=nil, sock: socket)
    if content
      @handler = Elva::Handlers::Karma.new(sock, 'elva', msg(content))
      @handler.match?
      @handler.process
    end
    @handler
  end

  let(:socket) { stub(puts: nil) }
  let(:handler) { @handler }

  describe 'matcher' do
    it "increment operator" do
      handle_message('samflores++').operator.must_equal '++'
    end

    it "decrement operator" do
      handle_message('samflores--').operator.must_equal '--'
    end

    it "understands CamelCase names" do
      handle_message("InfoSlack++")
      handler.operator.must_equal '++'
      handler.user.must_equal 'InfoSlack'
    end

    it "invalid operatos" do
      handle_message('samflores-+').operator.must_be_nil
      handle_message('samflores+-').operator.must_be_nil
    end

    it "operator is not at end of nickname" do
      handle_message('samflores--other text').operator.must_be_nil
    end

    it "there is text before the nickname" do
      handle_message('you are dumb, samflores--').operator.must_equal '--'
    end
  end

  describe 'process' do
    before { FileUtils.rm_rf(ENV['KARMA_PSTORE_URI']) }

    it 'increments karma' do
      handle_message('samflores++')
      handler.store.transaction(true) do
        handler.store[:karma]['samflores'].must_equal 1
      end
    end

    it 'decrements karma' do
      handle_message('samflores--')
      handler.store.transaction(true) do
        handler.store[:karma]['samflores'].must_equal -1
      end
    end

    it 'broadcasts the stats' do
      socket = mock
      socket.expects(:puts).with('PRIVMSG #devbr :Melhor karma: samflores (2)')
      socket.expects(:puts).with('PRIVMSG #devbr :Pior karma: samflores (2)')

      handle_message('samflores++')
      handle_message('samflores++')
      handle_message('!karma', sock: socket)
    end
  end
end
