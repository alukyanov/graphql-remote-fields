require 'graphql'

if Gem::Version.new(GraphQL::VERSION) < Gem::Version.new('1.3')
  warn 'graphql gem versions less than 1.3 are deprecated, upgrade so lazy_resolve can be used'
end

module GraphQL
  module RemoteFields
    META_KEYS = %i[remote remote_resolver remote_query].freeze
    class RemoteResolverNotFound < ArgumentError; end
    class RemoteQueryExecutionError < StandardError; end

    def self.use(schema_def, remote_resolver: nil)
      remote_fields = Plugin.new(remote_resolver: remote_resolver)
      schema_def.instrument(:field, remote_fields)
      schema_def.lazy_resolve(::Concurrent::Future, :value!)
    end

    def self.accept_definitions
      if GraphQL::ObjectType.respond_to?(:accepts_definitions) # < 1.8
        META_KEYS.each do |meta_key|
          GraphQL::ObjectType.accepts_definitions(
            meta_key => GraphQL::Define.assign_metadata_key(meta_key)
          )
          GraphQL::Field.accepts_definitions(
            meta_key => GraphQL::Define.assign_metadata_key(meta_key)
          )
        end
      end

      if Object.const_defined?('GraphQL::Schema::Object') &&
        GraphQL::Schema::Object.respond_to?(:accepts_definition) # >= 1.8

        META_KEYS.each do |meta_key|
          GraphQL::Schema::Object.accepts_definition(meta_key)
          GraphQL::Schema::Field.accepts_definition(meta_key)
        end
      end
    end
  end
end

GraphQL::RemoteFields.accept_definitions

require 'graphql/client'
require 'graphql/remote_fields/version'
require 'graphql/remote_fields/plugin'
require 'graphql/remote_fields/client'
require 'graphql/remote_fields/query_builder'
require 'graphql/remote_fields/resolvers/base'
