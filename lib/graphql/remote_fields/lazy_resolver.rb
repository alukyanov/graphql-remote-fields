module GraphQL
  module RemoteFields
    # Wrapper on the Concurrent::Future
    # Lazy requests parallel execution implemented using it.
    class LazyResolver < Concurrent::Future
      def self.execute(opts = {}, &block)
        LazyResolver.new(opts, &block).execute
      end
    end
  end
end
