module RemoteQuerySchema
  module Types
    class BaseObject < GraphQL::Schema::Object
      include GraphQL::RemoteFields

      remote_resolver Utils::GithubResolver.instance
    end

    class Stub < BaseObject
      field :id, GraphQL::Types::ID, null: true
      field :name, String, null: true
    end

    class Query < BaseObject
      field :stub, Types::Stub, null: false,
            remote: true, remote_query: -> (obj, ctx) { "query {\n    stub {\n  id\n name\n}\n  }\n" }
    end

    class Schema < GraphQL::Schema
      query Query
    end
  end
end
