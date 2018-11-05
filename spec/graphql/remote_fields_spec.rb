RSpec.describe GraphQL::RemoteFields do
  context 'mixins inclusions' do
    it 'Fields includes mixin from RemoteFields' do
      expect(FullSchema::Types::Query.field_class.ancestors).to include(described_class::Field::Mixin)
    end
  end

  context 'full schema' do
    let(:github_repo_id) { 'qwe=' }
    let(:github_repo_name) { 'repo' }

    let(:github_user_id) { 'id=' }
    let(:github_user_login) { 'alukyanov' }

    before do
      allow_any_instance_of(GraphQL::RemoteFields::Client).to receive(:execute) do |_client, raw_graphql, _variables|
        if raw_graphql.include?('repository')
          Utils::TestRepoResult.new('repository' => {
              'id'    => github_repo_id,
              'name'  => github_repo_name
          })
        else
          Utils::TestUserResult.new('user' => {
              'id'    => github_user_id,
              'login' => github_user_login
          })
        end
      end
    end

    context 'big ugly spec' do
      let(:variables) do
        {
            'username' => 'alukyanov',
            'reponame' => 'worker'
        }
      end
      let(:context) do
        {
            github_key: 'github_key'
        }
      end

      let(:query) do
        "
  query($username: String!, $reponame: String!) {
    remoteResults {
      user(login: $username) {
        id
        login
      }
      repository(name: $reponame, owner: $username) {
        id
        name
      }
    }
  }"
      end

      it 'has correct response' do
        schema_result = FullSchema::Types::Schema.execute(query, variables: variables, context: context)
        schema_data_result = schema_result['data']['remoteResults']

        aggregate_failures do
          expect(schema_result).to be_a(GraphQL::Query::Result)
          expect(schema_data_result['user']['id']).to eq(github_user_id)
          expect(schema_data_result['user']['login']).to eq(github_user_login)

          expect(schema_data_result['repository']['id']).to eq(github_repo_id)
          expect(schema_data_result['repository']['name']).to eq(github_repo_name)
        end
      end

      context 'remote resolver' do
        it '#resolve_remote_field called' do
          expect(Utils::GithubResolver.instance).to receive(:resolve_remote_field).once
          expect(Utils::GithubResolver.another_instance).to receive(:resolve_remote_field).once

          FullSchema::Types::Schema.execute(query, variables: variables, context: context)
        end
      end
    end
  end

  context 'no remote schema' do
    let(:query) do
      "
  query {
    posts {
      id
      title
    }
  }"
    end

    it '#resolve_remote_field never called' do
      expect(Utils::GithubResolver.instance).to_not receive(:resolve_remote_field)

      NoRemoteSchema::Types::Schema.execute(query)
    end
  end

  context 'remote_query option' do
    let(:query_with_only_id) do
      "
  query {
    stub {
      id
    }
  }"
    end

    let(:query_with_id_and_name) do
      "query {\n    stub {\n  id\n name\n}\n  }\n"
    end

    before do
      allow_any_instance_of(GraphQL::RemoteFields::Client).to receive(:execute) do |_client, _raw_graphql, _variables|
        expect(_raw_graphql).to eq query_with_id_and_name

        Utils::TestStubResult.new('stub' => {
            'id'    => 'id',
            'name'  => 'name'
        })
      end
    end

    it 'works' do
      result = RemoteQuerySchema::Types::Schema.execute(query_with_only_id)
      expect(result['data']['stub']).to include 'id'
      expect(result['data']['stub']).to_not include 'name'
    end
  end
end
