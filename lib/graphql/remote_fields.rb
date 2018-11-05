require 'graphql/client'
require 'graphql/remote_fields/version'
require 'graphql/remote_fields/client'
require 'graphql/remote_fields/query_builder'
require 'graphql/remote_fields/lazy_resolver'
require 'graphql/remote_fields/resolvers/base'
require 'graphql/remote_fields/field/mixin'

module GraphQL
  # Include this mixin into YourQuery inherited from GraphQL::Schema::Object
  # Entry point for getting remotes resolvers work.
  module RemoteFields
    class RemoteResolverNotFound < ArgumentError; end
    class RemoteQueryExecutionError < StandardError; end

    def self.included(base)
      base.extend(ClassMethods)
      base.field_class.prepend(Field::Mixin)
    end

    # Find remote resolver which will resolve fields by default
    # @return [< Resolvers::Base]
    def default_remote_resolver
      ancestor = self.class.ancestors.find do |ancestor|
        ancestor.instance_variable_defined?(:@_default_remote_resolver)
      end

      ancestor.instance_variable_get(:@_default_remote_resolver)
    end

    module ClassMethods
      # @param resolver must respond to #resolve
      # @return resolver
      def remote_resolver(resolver)
        @_default_remote_resolver = resolver
      end
    end
  end
end
