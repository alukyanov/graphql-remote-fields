module GraphQL
  module RemoteFields
    module Resolvers
      class Base
        attr_reader :url, :headers

        def initialize(url:, **kwargs)
          @url = url
          @headers = kwargs[:headers] || {}
        end

        # Entry point for remote resolvers.
        # Returns a response from the remote server.
        # @param obj    [GraphQL::Schema::Object]
        # @param args     [GraphQL::Query::Arguments]
        # @param context  [GraphQL::Query::Context]
        def resolve(obj, args, context, **kwargs)
          resolve_remote_field(obj, context)

          QueryBuilder.new(context).yield_self do |query_builder|
            client_query = kwargs[:predefined_query] || query_builder.build
            client_variables = query_builder.expose_args(args)

            response = client.execute(client_query, variables: client_variables)
            response.public_send(context.ast_node.name)
          end
        end

        # Overwrite this method in classes inherited from Resolvers::Base
        # You can modify headers etc based on context in this method.
        # @param _obj [GraphQL::Schema::Object]
        # @param _context [GraphQL::Query::Context]
        # @return not considered
        def resolve_remote_field(_obj, _context); end

        private

        def client
          @client ||= client_class.new(url, headers)
        end

        def client_class
          Client
        end
      end
    end
  end
end
