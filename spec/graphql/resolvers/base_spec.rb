RSpec.describe GraphQL::RemoteFields::Resolvers::Base do
  let(:endpoint) { 'https://api.github.com/graphql' }
  let(:headers) { { 'token' => 'token' } }

  let(:resolver) { described_class.new(url: endpoint, headers: headers) }

  let(:obj) { Object.new }
  let(:args) { Object.new }
  let(:ctx) do
    double('Context',
      query: '',
      ast_node: double('node', name: '')
    )
  end
  let(:metadata) { {} }

  before do
    allow_any_instance_of(GraphQL::RemoteFields::QueryBuilder)
      .to receive(:build)

    allow_any_instance_of(GraphQL::RemoteFields::QueryBuilder)
      .to receive(:expose_args)

    allow(GraphQL::RemoteFields::Client).to receive(:execute)
      .with(instance_of(GraphQL::RemoteFields::Request))
  end

  describe '#resolve' do
    it 'call #resolve_remote_field' do
      expect(resolver).to receive(:resolve_remote_field)
        .with(obj: obj, ctx: ctx, request: instance_of(GraphQL::RemoteFields::Request))
        .and_return(GraphQL::RemoteFields::Request.new)

      resolver.resolve(obj, args, ctx, metadata)
    end

    it 'call #build_request' do
      expect(resolver).to receive(:build_request)
        .with(obj, args, ctx, metadata).and_call_original

      resolver.resolve(obj, args, ctx, metadata)
    end

    it 'call Client#execute with request' do
      expect(GraphQL::RemoteFields::Client).to receive(:execute)
        .with(instance_of(GraphQL::RemoteFields::Request))

      resolver.resolve(obj, args, ctx, metadata)
    end
  end

  describe '#build_request' do
    context 'with remote_query in metadata' do
      let(:overriden_query) { 'query { fields ... }' }
      let(:metadata) do
        {
          remote_query: ->(obj, ctx) { overriden_query }
        }
      end

      let(:request) { resolver.build_request(obj, args, ctx, metadata) }

      it 'work' do
        expect(request.query).to eq overriden_query
      end
    end
  end
end
