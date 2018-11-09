class GithubRepo < GraphQL::Schema::Object
  field :id, String, null: false
  field :name, String, null: false
end
