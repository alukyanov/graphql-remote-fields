require_relative '../types/post_type'

class LocalQuery < GraphQL::Schema::Object
  field :posts, [PostType], null: false do
    argument :login, String, required: true
  end

  def posts(login)
    [
      {
        id: 1,
        title: 'title'
      }
    ]
  end
end
