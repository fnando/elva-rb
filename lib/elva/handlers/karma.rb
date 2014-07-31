require 'pstore'

module Elva
  module Handlers
    class Karma < Base
      attr_reader :operator, :stats

      def active?
        store_uri
      end

      def match?
        _, @operator = *message.match(/([+-]{2})/)
        @stats = content.to_s.match(/\A!karma/)
        @operator || @stats
      end

      def process
        compute_karma if operator
        send_stats if stats
      end

      def send_stats
        store.transaction(true) do
          karma = (store[:karma] || {}).to_a

          stats_for_best(karma)
          stats_for_worst(karma)
        end
      end

      def stats_for_worst(karma)
        return unless karma.size.nonzero?
        worst = karma.sort_by {|(nickname, score)| score }[0, 3]
        broadcast t('karma.worst', list: format(worst))
      end

      def stats_for_best(karma)
        return unless karma.size.nonzero?
        best = karma.sort_by {|(nickname, score)| score }.reverse[0, 3]
        broadcast t('karma.best', list: format(best))
      end

      def format(list)
        list
          .map {|(nickname, score)| "#{nickname} (#{score})" }
          .join(', ')
      end

      def compute_karma
        # Don't compute karma for the bot.
        return if user == nickname

        # Don't compute karma gain for sender
        return if user == sender && gain?

        store.transaction do
          store[:karma] ||= {}
          store[:karma][user] ||= 0
          store[:karma][user] += score

          broadcast t(action, scope: 'karma', level: store[:karma][user], nickname: user)
        end
      end

      def gain?
        operator == '++'
      end

      def action
        gain? ? 'gain' : 'lose'
      end

      def score
        gain? ? 1 : -1
      end

      def store_uri
        ENV['KARMA_PSTORE_URI']
      end

      def store
        @store ||= PStore.new(store_uri)
      end

      def user
        @user ||= message[/(?:([a-z0-9-_]+)[+-]{2})/i, 1]
      end
    end
  end
end
