module Utils
  class GithubResolver < GraphQL::RemoteFields::Resolvers::Base
    def self.instance
      @@instance ||= GithubResolver.new(url: 'https://api.github.com/graphql')
    end

    def resolve_remote_field(obj:, ctx:, current_result:)
      headers['Authorization'] = "Bearer #{ctx[:github_key]}"
      headers['User-Agent'] = 'Ruby'

      current_result
    end
  end
end
