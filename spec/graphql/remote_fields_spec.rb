RSpec.describe GraphQL::RemoteFields do
  context 'local schema' do
    let(:query) do
      <<-'GRAPHQL'
        query {
          posts {
            id
            title
          }
        }
      GRAPHQL
    end

    it 'resolves as usual' do
      expect(WebMock).not_to have_requested(:post, github_url)
      resp = LocalSchema.execute(query)
      expect(resp['data'].keys).to include 'posts'
      expect(resp['data']['posts'][0]['id']).to eq '1'
      expect(resp['data']['posts'][0]['title']).to eq 'title'
    end
  end

  context 'remote schema' do
    let(:query) do
      <<-'GRAPHQL'
        query ($repo: String!, $owner: String!) {
          user(login: $owner) {
            id
            login
          }
          repository(name: $repo, owner: $owner) {
            id
            name
          }
        }
      GRAPHQL
    end

    it 'contains responses for to remote queries' do
      resp = RemoteSchema.execute(query,
                                  variables: { owner: 'alukyanov', repo: 'worker' },
                                  context: { github_key: 'key' })
      expect(resp['data'].keys).to include 'user'
      expect(resp['data'].keys).to include 'repository'
      expect(resp['data']['user']['id']).to eq user_id
      expect(resp['data']['user']['login']).to eq user_login
      expect(resp['data']['repository']['id']).to eq repo_id
      expect(resp['data']['repository']['name']).to eq repo_name
    end
  end

  context 'mixed schema' do
    let(:query) do
      <<-'GRAPHQL'
        query ($repo: String!, $owner: String!) {
          posts {
            id
            title
          }
          user(login: $owner) {
            id
            login
          }
          repository(name: $repo, owner: $owner) {
            id
            name
          }
        }
      GRAPHQL
    end

    it 'contains responses from local and remote queries' do
      resp = MixedSchema.execute(query,
                                 variables: { owner: 'alukyanov', repo: 'worker' },
                                 context: { github_key: 'key' })
      expect(resp['data'].keys).to include 'posts'
      expect(resp['data'].keys).to include 'user'
      expect(resp['data'].keys).to include 'repository'

      expect(resp['data']['posts'][0]['id']).to eq '1'
      expect(resp['data']['posts'][0]['title']).to eq 'title'
      expect(resp['data']['user']['id']).to eq user_id
      expect(resp['data']['user']['login']).to eq user_login
      expect(resp['data']['repository']['id']).to eq repo_id
      expect(resp['data']['repository']['name']).to eq repo_name
    end
  end


  let(:introspection_schema) { GraphQL::Client.load_schema("#{__dir__}/../support/dumped_schemas/github.json") }

  before do
    stub_request(:post, github_url)
      .to_return(body: lambda do |request|
        request.body.include?('repo') ? repo_response : user_response
      end)

    allow(GraphQL::Client).to receive(:dump_schema).and_return(introspection_schema)
    allow(GraphQL::RemoteFields::Client).to receive(:load_schema)
      .and_return(introspection_schema)

    allow(Concurrent::Future).to receive(:execute) do |&block|
      block.call
    end
  end

  let(:github_url) { 'https://api.github.com/graphql' }
  let(:user_id) { 'id=' }
  let(:user_login) { 'alukyanov' }
  let(:repo_id) { 'id=' }
  let(:repo_name) { 'worker' }

  let(:user_response) do
    <<-JSON
        {
          "data": {
              "user": {
                  "id": "#{user_id}",
                  "login": "#{user_login}"
              }
          }
        }
    JSON
  end

  let(:repo_response) do
    <<-JSON
        {
          "data": {
            "repository": {
              "id": "#{repo_id}",
              "name": "#{repo_name}"
            }
          }
        }
    JSON
  end
end
