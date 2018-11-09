RSpec.describe GraphQL::RemoteFields::Plugin do
  let(:instance) { described_class.new(remote_resolver: nil) }

  describe '#use' do
    let(:schema) { double(:schema, instrument: nil) }

    it 'should inject the plugin' do
      expect(schema).to receive(:instrument).with(:field, an_instance_of(described_class))
      instance.use(schema)
    end
  end

  describe '#instrument' do
    let(:type) { double(:type, metadata: { remote_resolver: :stub }) }
    let(:field) { double(:field, redefine: nil, metadata: { remote: remote, remote_resolver: :stub }) }

    context 'with remote option in field' do
      let(:remote) { true }

      it 'call field#redefine' do
        expect(field).to receive(:redefine)
        instance.instrument(type, field)
      end
    end

    context 'with remote option in field' do
      let(:remote) { false }

      it "'doesn't call field#redefine" do
        expect(field).to_not receive(:redefine)
        instance.instrument(type, field)
      end
    end
  end
end
