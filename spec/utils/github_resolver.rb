module Utils
  class GithubResolver < GraphQL::RemoteFields::Resolvers::Base
    def self.instance
      @@instance ||= GithubResolver.new(url: 'https://api.github.com/graphql')
    end

    def resolve_remote_field(obj:, ctx:, request:)
      request.headers['Authorization'] = "Bearer #{ctx[:github_key]}"
      request.headers['User-Agent'] = 'Ruby'
      request
    end
  end
end
