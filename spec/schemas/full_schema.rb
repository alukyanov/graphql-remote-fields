# In this schema we testing both options
# default remote resolver as class_method remote_resolver (:repository)
# and :remote_resolver option in Field (:user)
module FullSchema
  module Types
    class BaseObject < GraphQL::Schema::Object
      include GraphQL::RemoteFields

      remote_resolver Utils::GithubResolver.instance
    end

    class GithubUser < BaseObject
      field :id, String, null: false
      field :login, String, null: false
    end

    class GithubRepo < BaseObject
      field :id, String, null: false
      field :name, String, null: false
    end

    class RemoteResults < BaseObject
      field :user,
            Types::GithubUser,
            null: false,
            remote: true,
            remote_resolver: :github_resolver do
        argument :login, String, required: true
      end

      field :repository,
            Types::GithubRepo, null: false,
            remote: true do
        argument :owner, String, required: true
        argument :name, String, required: true
      end

      def github_resolver
        @github_resolver ||= Utils::GithubResolver.another_instance
      end
    end

    class Query < BaseObject
      field :remoteResults, Types::RemoteResults, null: false

      def remote_results
        {}
      end
    end

    class Schema < GraphQL::Schema
      query Query
    end
  end
end
