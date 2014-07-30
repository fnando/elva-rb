module Elva
  module Handlers
    class Github < Base
      attr_reader :username, :repo

      def match?
        _, @username, @repo = *content.to_s.match(/\A!gh (.*?)(?:\/(.*?))?\z/)
        username
      end

      def process
        process_user_info unless repo
        process_repo_info if repo
      end

      def params
        {username: username, repo: repo}
      end

      def process_user_info
        response = Aitch.get('https://api.github.com/users/%s' % username)
        return broadcast t('github.user_not_found', params) unless response.ok?

        data = OpenStruct.new(response.data)
        info = data.name
        info << (' (%s)' % data.location) if data.location
        info << ' ' << t('github.works_for', company: data.company) if data.company
        info << ' ~ ' << data.html_url

        broadcast info
      end

      def process_repo_info
        response = Aitch.get('https://api.github.com/repos/%s/%s' % [username, repo])
        return broadcast t('github.repo_not_found', params) unless response.ok?

        data = OpenStruct.new(response.data)
        info = data.name
        info << ': ' << data.description if data.description
        info << ' ~ ' << data.html_url

        broadcast info
      end
    end
  end
end
