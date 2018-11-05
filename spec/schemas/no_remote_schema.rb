module NoRemoteSchema
  module Types
    class BaseObject < GraphQL::Schema::Object
      include GraphQL::RemoteFields

      remote_resolver Utils::GithubResolver.instance
    end

    class Post < BaseObject
      field :id, GraphQL::Types::ID, null: false
      field :title, String, null: false
    end

    class Query < BaseObject
      field :posts,
            [Types::Post],
            null: false

      def posts
        [
          {
              id: 1,
              title: 'title'
          }
        ]
      end
    end

    class Schema < GraphQL::Schema
      query Query
    end
  end
end
