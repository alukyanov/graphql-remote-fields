require_relative '../types/github_user'
require_relative '../types/github_repo'

class MixedQuery < GraphQL::Schema::Object
  field :posts, [PostType], null: false

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

  def posts
    [
      {
        id: 1,
        title: 'title'
      }
    ]
  end
end
