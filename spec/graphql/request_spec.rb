RSpec.describe GraphQL::RemoteFields::Request do
  let(:endpoint) { 'https://endpoint.com' }
  let(:headers) do
    { 'Authorization' => 'Bearer token' }
  end

  describe '#common_hash' do
    let(:instance_params) do
      {
        endpoint: endpoint,
        headers: headers
      }
    end

    let(:instance_extra_params) do
      {
        query:      'query {fields1 ...}',
        vars:       { a: 1 },
        root_node: 'root1'
      }
    end

    let(:instance) { described_class.new(instance_params.merge(instance_extra_params)) }
    let(:another_instance) { described_class.new(instance_params.merge(extra_params)) }

    subject { instance.common_hash == another_instance.common_hash }

    context 'with same endpoint and headers' do
      let(:extra_params) do
        {
          query:      'query {fields2 ...}',
          vars:       { a: 2 },
          root_node: 'root2'
        }
      end

      context 'but other params are different' do
        it { is_expected.to be_truthy }
      end
    end

    context 'with different headers' do
      let(:extra_params) do
        {
          headers:    headers.merge(z: 1),
          query:      'query {fields2 ...}',
          vars:       { a: 2 },
          root_node: 'root2'
        }
      end

      it { is_expected.to be_falsey }
    end

    context 'with different endpoint' do
      let(:extra_params) do
        {
          endpoint:   "#{endpoint}.edu",
          query:      'query {fields2 ...}',
          vars:       { a: 2 },
          root_node: 'root2'
        }
      end

      it { is_expected.to be_falsey }
    end
  end
end
