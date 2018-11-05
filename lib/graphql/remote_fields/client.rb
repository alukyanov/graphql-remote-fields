require 'graphql/remote_fields/client/http_client'

module GraphQL
  module RemoteFields
    # Wrapper on the GraphQL::Client
    class Client
      attr_reader :url, :headers

      def initialize(url, headers)
        @url = url
        @headers = headers
      end

      # Executes raw GraphQL query by GraphQL::Client
      # @param raw_graphql [String] query will sent to server
      # @param variables [Hash] with defined variables in this Hash
      def execute(raw_graphql, variables = {})
        query = client.parse(raw_graphql)
        response = client.query(query, variables)
        raise response.errors[:data].join(', ') if response.errors.any?

        response.data
      rescue => e
        raise RemoteQueryExecutionError.new <<-ERR
Cannot execute query #{raw_graphql}; 
url: #{url};
headers: #{headers};
error: #{e.message}
ERR
      end

      private

      def client
        @client ||= begin
          GraphQL::Client.new(schema: load_schema, execute: http_client).tap do |client|
            client.allow_dynamic_queries = true
          end
        end
      end

      # TODO: cache schema into file dumps based on resolver
      def load_schema
        GraphQL::Client.load_schema(http_client)
      end

      def http_client
        @http_client ||= HttpClient.new(url, headers)
      end
    end
  end
end
