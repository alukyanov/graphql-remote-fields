module GraphQL
  module RemoteFields
    # QueryBuilder build graphql query for some part of schema
    class QueryBuilder
      attr_reader :query, :ast_node

      def initialize(query, ast_node)
        @query    = query
        @ast_node = ast_node
      end

      def build
        <<-GRAPHQL
          query #{node_variables} {
            #{node_query}
          }
        GRAPHQL
      end

      def expose_args(args)
        node_arguments.each_with_object({}) do |arg, result|
          result[arg.value.name] = args[arg.name]
        end
      end

      private

      def node_query
        ast_node.to_query_string
      end

      def node_variables
        arg_definitions = node_arguments.map { |arg| arg.value.name }
        node_variables = query_variables.select do |var|
          arg_definitions.include?(var.name)
        end

        return if node_variables.empty?

        "(#{node_variables.map(&:to_query_string).join(',')})"
      end

      def query_variables
        @query_variables ||= query.instance_variable_get(:@ast_variables)
      end

      def node_arguments
        @node_arguments ||= ast_node.arguments
      end
    end
  end
end
