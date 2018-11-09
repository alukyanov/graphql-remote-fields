class GithubUser < GraphQL::Schema::Object
  field :id, String, null: false
  field :login, String, null: false
end
