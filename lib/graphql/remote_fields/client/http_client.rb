require 'graphql/client/http'

module GraphQL
  module RemoteFields
    class Client
      # Wrapper on the GraphQL::Client::HTTP
      class HttpClient < GraphQL::Client::HTTP
        def initialize(uri, headers)
          super(uri)
          @headers = headers || {}
        end

        def headers(_context)
          @headers
        end
      end
    end
  end
end
