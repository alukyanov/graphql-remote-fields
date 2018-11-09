require_relative '../queries/mixed_query'

class MixedSchema < GraphQL::Schema
  use GraphQL::RemoteFields, remote_resolver: Utils::GithubResolver.instance

  query MixedQuery
end
