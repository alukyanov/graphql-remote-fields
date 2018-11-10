module GraphQL
  module RemoteFields
    Request = Struct.new(
      :endpoint,  # request will sent to this url
      :headers,   # request will sent with this headers
      :query,     # graphql query
      :vars,      # vars to be sent with graphql query
      :root_node, # expected root node name in response
      keyword_init: true
    ) do

      def hash
        @hash ||= [endpoint, headers].hash
      end
    end
  end
end
