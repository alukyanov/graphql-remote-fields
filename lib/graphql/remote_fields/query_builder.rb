module GraphQL
  module RemoteFields
    class QueryBuilder
      attr_reader :context

      def initialize(context)
        @context = context
      end

      def build
        variables_definitions = variable_definitions_for_context
                                .map(&:to_query_string).join(', ')

        context_query = context.ast_node.to_query_string

        <<-QUERY
  query (#{variables_definitions}) {
    #{context_query}
  }
        QUERY
      end

      def expose_args(args)
        context_args.each_with_object({}) do |arg, result|
          result[arg.value.name] = args[arg.name]
        end
      end

      private

      def variable_definitions_for_context
        @variable_definitions_for_context ||= begin
          definition_for_context.variables.select do |var|
            context_args_value_names.include?(var.name)
          end
        end
      end

      def context_args_value_names
        @context_args_value_names ||= context_args.map do |arg|
          arg.value.name
        end
      end

      def context_args
        @context_args ||= context.ast_node.arguments
      end

      def definition_for_context
        context.query.document.definitions.find do |definition|
          definition.selections.find do |selection|
            found_selection = find_selection(selection, context.ast_node)
            break found_selection if found_selection
          end
        end
      end

      def find_selection(selection_node, target_selection)
        return unless selection_node
        return selection_node if selection_node == target_selection

        selection_node.selections.find do |internal_selection|
          find_selection(internal_selection, target_selection)
        end
      end
    end
  end
end
