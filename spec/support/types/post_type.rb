class PostType < GraphQL::Schema::Object
  description 'Post'
  graphql_name 'Post'

  field :id, ID, null: false
  field :title, String, null: false
end
