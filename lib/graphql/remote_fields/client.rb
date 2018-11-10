module GraphQL
  module RemoteFields
    # Wrapper on the GraphQL::Client
    class Client
      # Wrapper on GraphQL::Client::HTTP
      # to send headers in constructor
      class HttpClient < ::GraphQL::Client::HTTP
        def initialize(uri, headers)
          super(uri)
          @headers = headers || {}
        end

        def headers(_context)
          @headers
        end
      end

      attr_reader :request

      def self.execute(request)
        new(request).execute
      end

      def self.schemas
        @schemas ||= {}
      end

      def initialize(request)
        @request = request
      end

      def execute
        client = graphql_client
        query = client.parse(request.query)
        response = client.query(query, variables: request.vars)

        raise response.errors[:data].join(', ') if response.errors.any?

        response.data.send(request.root_node)
      rescue StandardError => e
        raise RemoteQueryExecutionError, <<-ERR
          Cannot execute query #{request.query};
          url: #{request.endpoint};
          headers: #{request.headers};
          error: #{e.message}
        ERR
      end

      private

      def graphql_client
        GraphQL::Client.new(schema: schema, execute: http_client).tap do |client|
          client.allow_dynamic_queries = true
        end
      end

      def schema
        schemas[request.common_hash] ||= GraphQL::Client.load_schema(http_client)
      end

      def http_client
        @http_client ||= HttpClient.new(request.endpoint, request.headers)
      end

      def schemas
        self.class.schemas
      end
    end
  end
end
