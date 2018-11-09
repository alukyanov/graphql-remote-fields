require_relative '../queries/remote_query'

class RemoteSchema < GraphQL::Schema
  use GraphQL::RemoteFields, remote_resolver: Utils::GithubResolver.instance

  query RemoteQuery
end
