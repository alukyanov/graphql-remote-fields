module GraphQL
  module RemoteFields
    class Plugin
      attr_reader :remote_resolver

      def initialize(remote_resolver:)
        @remote_resolver = remote_resolver
      end

      def use(schema_definition)
        schema_definition.instrument(:field, self)
      end

      def instrument(type, field)
        return field unless field.metadata[:remote]

        resolver = find_remote_resolver(type, field)

        field.redefine do
          resolve ->(obj, args, ctx) {
            Concurrent::Future.execute do
              resolver.resolve(obj, args, ctx, field.metadata[:remote_query])
            end
          }
        end
      end

      def find_remote_resolver(type, field)
        resolver = field.metadata[:remote_resolver] ||
                   type.metadata[:remote_resolver] ||
                   remote_resolver

        unless resolver
          raise RemoteResolverNotFound, 'Remote resolver was not found'
        end

        resolver
      end
    end
  end
end
