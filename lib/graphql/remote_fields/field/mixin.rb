module GraphQL
  module RemoteFields
    module Field
      # This mixin defines how Field resolves with remote resolvers
      # It will automatically included in Fields defined in Query
      # But only for Query which includes RemoteFields.
      module Mixin
        def initialize(*args, **kwargs, &block)
          @_remote_options = {
            remote:           kwargs.delete(:remote),
            remote_resolver:  kwargs.delete(:remote_resolver),
            remote_query:     kwargs.delete(:remote_query)
          }
          super(*args, **kwargs, &block)
        end

        # Main entry point to resolver field's value
        def resolve_field(obj, args, ctx)
          return super(obj, args, ctx) unless @_remote_options[:remote]

          init_lazy_on_schema(ctx.schema)

          ctx.schema.after_lazy(obj) do |_after_obj|
            LazyResolver.execute do
              remote_resolve(obj, args, ctx)
            end
          end
        end

        private

        # HACK: all remote resolver graphql queries will run in parallel
        def init_lazy_on_schema(schema)
          schema.instance_variable_get(:@lazy_methods).set(LazyResolver, :value!)
        end

        # Build graphql query, arguments.
        # Send it to server.
        # Returns response from server.
        def remote_resolve(obj, args, ctx)
          resolver  = field_remote_resolver(obj)
          kwargs    = build_kwargs_for_resolver(obj, ctx)
          resolver.resolve(obj, args, ctx, kwargs)
        end

        # Find remote resolver which resolve current Field
        # @return [< Resolvers::Base]
        def field_remote_resolver(obj)
          remote_resolver = @_remote_options[:remote_resolver] ||
            obj.default_remote_resolver

          unless remote_resolver
            raise RemoteResolverNotFound, "Remote resolver not found for #{self.class}"
          end

          if remote_resolver.respond_to?(:call)
            remote_resolver.call
          elsif remote_resolver.is_a?(Symbol) && obj.respond_to?(remote_resolver)
            obj.method(remote_resolver).call
          else
            remote_resolver
          end
        end

        # Set up remote resolver's options
        # Returns a hash to set up resolver
        # Supported options in return:
        # :predefined_query - query, returned by Field's lambda
        # lambda's attr on Field named :remote_query
        # @return [Hash]
        def build_kwargs_for_resolver(obj, context)
          {}.tap do |result|
            remote_query = field_remote_query(obj)

            if remote_query
              result[:predefined_query] = remote_query.call(obj, context)
            end
          end
        end

        # Executes lambda defined in Field's remote_query
        # Returns result of execution
        # @return [String]
        def field_remote_query(obj)
          remote_query = @_remote_options[:remote_query]
          return unless remote_query

          if remote_query.respond_to?(:call)
            remote_query
          elsif remote_query.is_a?(Symbol) && obj.respond_to?(remote_query)
            obj.method(remote_query)
          end
        end
      end
    end
  end
end
