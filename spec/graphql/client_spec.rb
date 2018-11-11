RSpec.describe GraphQL::RemoteFields::Client do
  let(:endpoint) { 'https://api.github.com/graphql' }
  let(:introspection_schema) { GraphQL::Client.load_schema("#{__dir__}/../support/dumped_schemas/github.json") }

  let(:query_string) do
    <<-'GRAPHQL'
      query ($owner: String!) {
        user(login: $owner) {
          id
          login
        }
      }
    GRAPHQL
  end

  let(:result) do
    <<-JSON
  {
    "data": {
      "user": {
        "id": "id=",
        "login": "alukyanov"
      }
    }
  }
    JSON
  end

  let(:headers) { { 'token' => 'token' } }

  let(:request) do
    GraphQL::RemoteFields::Request.new(
      endpoint:   endpoint,
      headers:    headers,
      query:      query_string,
      vars:       {},
      root_node:  'user'
    )
  end

  before do
    allow(GraphQL::Client).to receive(:dump_schema).and_return(introspection_schema)
    allow(GraphQL::Client).to receive(:load_schema).and_return(introspection_schema)

    stub_request(:post, endpoint).to_return(body: result)
  end

  it 'works' do
    GraphQL::RemoteFields::Client.execute(request)

    expect(WebMock).to have_requested(:post, endpoint).with(headers: headers)
  end
end
