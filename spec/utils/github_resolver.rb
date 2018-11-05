module Utils
  class GithubResolver < GraphQL::RemoteFields::Resolvers::Base
    def self.instance
      @@instance ||= GithubResolver.new(url: 'https://api.github.com/graphql')
    end

    def self.another_instance
      @@another_instance ||= GithubResolver.new(url: 'https://api.github.com/graphql')
    end

    def resolve_remote_field(_query, context)
      headers["Authorization"] = "Bearer #{context[:github_key]}"
      headers["User-Agent"] = 'Ruby'
    end
  end
end
