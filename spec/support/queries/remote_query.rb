require_relative '../types/github_user'
require_relative '../types/github_repo'

class RemoteQuery < GraphQL::Schema::Object
  field :user,
        GithubUser,
        null: false,
        remote: true do
    argument :login, String, required: true
  end

  field :repository,
        GithubRepo, null: false,
        remote: true do
    argument :owner, String, required: true
    argument :name, String, required: true
  end
end
