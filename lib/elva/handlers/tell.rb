module Elva
  module Handlers
    class Tell < Base
      attr_reader :note, :user

      def active?
        store_uri
      end

      def match?
        true
      end

      def process
        save_note
        send_notes
      end

      def save_note?
        _, @user, @note = *content.to_s.match(/\A!tell ([^ ]+) (.*?)\z/)

        return unless user
        return unless note
        return if user == nickname
        return if user == sender

        true
      end

      def save_note
        return unless save_note?

        store.transaction do
          store[:notes] ||= {}
          store[:notes][user] ||= []
          store[:notes][user] << {
            from: sender,
            to: user,
            note: note
          }
        end
      end

      def send_notes
        store.transaction do
          next unless store[:notes]

          messages = store[:notes][sender] || []

          messages.each do |info|
            broadcast '%{from}: %{to} %{note}' % info
          end

          store[:notes][sender] = [] if messages.any?
        end
      end

      def store
        @store ||= PStore.new(store_uri)
      end

      def store_uri
        ENV['TELL_PSTORE_URI']
      end
    end
  end
end
