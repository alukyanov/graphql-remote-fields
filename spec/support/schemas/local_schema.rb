require_relative '../queries/local_query'

class LocalSchema < GraphQL::Schema
  use GraphQL::RemoteFields, remote_resolver: Utils::GithubResolver.instance

  query LocalQuery
end
