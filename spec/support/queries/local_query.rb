require_relative '../types/post_type'

class LocalQuery < GraphQL::Schema::Object
  field :posts, [PostType], null: false

  def posts
    [
      {
        id: 1,
        title: 'title'
      }
    ]
  end
end
