RSpec.describe ApplicationSerializer::Base do
  let(:model_attributes) { ({id: 1, name: 'Bender', catch_phrase: 'Bender is great'}) }
  let!(:subject) { Person.new(model_attributes) }

  describe 'default context' do
    context 'when an empty serializer is defined' do
      it 'returns an empty hash' do
        expect(
          Class.new(PersonSerializer).new(subject).to_json
        ).to eq({}.to_json)
      end
    end
  end

  describe 'when a context is not defined' do
    it 'returns the default context' do
      Ctx = Class.new(PersonSerializer) do
        context :default do |serialize|
          serialize.attributes :id
        end
      end

      expect(
        Ctx.new(subject, context: :undefined).to_json
      ).to eq({ id: subject.id }.to_json)
    end
  end

  describe 'explicit context' do
    context 'when a context is explicitly requests attributes' do
      it 'returns the defined attributes' do
        expect(
          Class.new(PersonSerializer).new(subject, context: :show).to_json
        ).to eq(model_attributes.to_json)
      end
    end

    context 'when a context value is specified' do
      it 'returns the defined attributes' do
        expect(
          Class.new(PersonSerializer).new(subject, context: :list).to_json
        ).to eq({ key: 1, value: 'Bender'}.to_json)
      end
    end

    context 'when a dynamic value is specified' do
      it 'returns the attribute' do
        expect(
          Class.new(PersonSerializer).new(subject, context: :byline).to_json
        ).to eq({ byline: "#{subject.name} says '#{subject.catch_phrase}'" }.to_json)
      end
    end
  end
end
