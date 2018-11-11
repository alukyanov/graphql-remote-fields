RSpec.describe GraphQL::RemoteFields::QueryBuilder do
  let(:variables) do
    {
      'owner' => 'alukyanov'
    }
  end

  let(:query_string) do
    <<-'GRAPHQL'
      query ($owner: String!) {
        posts(login: $owner) {
          id
          title
        }
      }
    GRAPHQL
  end

  let(:result) { LocalSchema.execute(query_string, variables: variables) }
  let(:context) { result.context }
  let(:builder) { described_class.new(context.query, context.ast_node.selections[0]) }
  let(:args) do
    {
      'login' => 'alukyanov'
    }
  end

  def normalize(str)
    str.split("\n").map(&:strip).join("\n")
  end

  describe '#build' do
    it 'have correct query' do
      expect(normalize(builder.build)).to eq normalize(query_string)
    end
  end

  describe '#expose_args' do
    it 'have correct vars' do
      expect(builder.expose_args(args)).to eq(variables)
    end
  end
end
