# GraphQL::RemoteFields

Implementation of queries stitching for Ruby GraphQL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-remote-fields'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-remote-fields

## Usage

At first include `GraphQL::RemoteFields` to query class inherited from `GraphQL::Schema::Object`.
To fields' class defined inside this query class, `GraphQL::RemoteFields::Field::Mixin` will prepended.
Remote queries will sent in parallel due to lazy mechanism of Ruby GraphQL.

**Field options:**
`remote` - set to true if you want to resolve field remotely.
`remote_resolver` - resolver instance which will configure request to server
`remote_query` - with this lambda you can customize query which will sent to server.

```ruby
field :user,
    Types::GithubUser,
    null: false,
    remote: true,  # only fields with remote: true will resolved remotely
    remote_resolver: :github_resolver, # custom resolver
    remote_query: -> (obj, ctx) { "query { user { id } }" } # override query to server
```

**Custom remote resolver**

You can override resolve_remote_field to set up headers using context.
Example:

```ruby
class GithubResolver < GraphQL::RemoteFields::Resolvers::Base
  def resolve_remote_field(_query, context)
    headers["Authorization"] = "Bearer #{context['github_key']}"
    headers["User-Agent"] = 'Ruby'
  end
end
```

Full example:

```ruby
module GraphqlAPI
  module Types
    class BaseObject < GraphQL::Schema::Object
      # including mixin
      include GraphQL::RemoteFields

      # Default resolver instance
      remote_resolver GithubResolver.new(url: "https://api.github.com/graphql")
    end
    
    class Post < BaseObject
      field :id, GraphQL::Types::ID, null: false
      field :title, String, null: false
    end
    
    class GithubUser < BaseObject
      field :id, String, null: true
      field :login, String, null: true
      field :name, String, null: true
      field :avatarUrl, String, null: true
      field :bio, String, null: true
      field :bioHTML, String, null: true
      field :location, String, null: true
    end

    class GithubRepo < BaseObject
      field :id, String, null: true
      field :name, String, null: true
    end

    class RemoteResults < BaseObject
      field :user,
            Types::GithubUser,
            null: false,
            remote: true,  # only fields with remote: true will resolved remotely
            remote_resolver: :github_resolver do # set custom resolver instead of default
        argument :login, String, required: true
      end
      
      field :repository,
            Types::GithubRepo, null: false,
            remote: true,
            remote_resolver: :github_resolver do # set custom resolver using symbol name of defined method
        argument :owner, String, required: true
        argument :name, String, required: true
      end

      def github_resolver
        @github_resolver ||= GithubResolver.new(url: 'https://api.github.com/graphql')
      end
    end

    class Query < BaseObject
      field :posts,
            [Types::Post],
            null: false

      field :remoteResults, Types::RemoteResults, null: false

      def remote_results
        {}
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

    class Schema < GraphQL::Schema
      query Query
    end
  end
end

# Define custom remote resolver class
# You can setup headers in overriden #resolve_remote_field using query and context
class GithubResolver < GraphQL::RemoteFields::Resolvers::Base
  def resolve_remote_field(_query, context)
    headers["Authorization"] = "Bearer #{context['github_key']}"
    headers["User-Agent"] = 'Ruby'
  end
end

# GraphQL query
query_string = "
query($username: String!, $reponame: String!) {
  remoteResults {
    user(login: $username) {
      id
      login
      name
      avatarUrl
      bio
      bioHTML
      location
    }
    repository(name: $reponame, owner: $username) {
      id
      name
    }
  }
}"
variables = {
  'username' => 'alukyanov',
  'reponame' => 'worker'
}

context = {
    'github_key' => 'token'
}
result = GraphqlAPI::Types::Schema.execute(short_query_string, variables: variables, context: context)

=> #<GraphQL::Query::Result @query=... @to_h={"data"=>{"posts"=>[{"id"=>"1", "title"=>"title"}], "remoteResults"=>{"user"=>{"id"=>"id=", "login"=>"alukyanov", "name"=>nil, "avatarUrl"=>"https://avatars1.githubusercontent.com/u/5574786?v=4", "bio"=>nil, "bioHTML"=>"", "location"=>nil}, "repository"=>{"id"=>"id=", "name"=>"worker"}}}}>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alukyanov/graphql-remote-fields. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
