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
        # @param obj      [GraphQL::Schema::Object]
        # @param args     [GraphQL::Query::Arguments]
        # @param ctx      [GraphQL::Query::Context]
        # @param metadata [Hash]
        def resolve(obj, args, ctx, metadata = {})
          raw_request = build_request(obj, args, ctx, metadata)
          request = resolve_remote_field(obj: obj, ctx: ctx, request: raw_request)

          Client.execute(request)
        end

        # Overwrite this method in classes inherited from Resolvers::Base
        # You can modify headers etc based on args in this method.
        # @param obj: [GraphQL::Schema::Object]
        # @param ctx: [GraphQL::Query::Context]
        # @param request: [GraphQL::RemoteFields::Request]
        # @return Must return [GraphQL::RemoteFields::Request]
        def resolve_remote_field(obj:, ctx:, request:)
          request
        end

        def build_request(obj, args, ctx, metadata)
          query_builder = QueryBuilder.new(ctx.query, ctx.ast_node)

          query = remote_query_from_metadata(metadata, obj, ctx) ||
                  query_builder.build

          vars = query_builder.expose_args(args)

          Request.new(
            endpoint:   url,
            headers:    headers,
            query:      query,
            vars:       vars,
            root_node:  ctx.ast_node.name)
        end

        private

        def remote_query_from_metadata(metadata, obj, ctx)
          return unless metadata[:remote_query]

          metadata[:remote_query].call(obj, ctx)
        end
      end
    end
  end
end
