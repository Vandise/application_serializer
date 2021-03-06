RSpec.describe ApplicationSerializer::Base do
  let(:model_attributes) { ({id: 1, name: 'Bender', catch_phrase: 'Bender is great'}) }
  let!(:subject) { Person.new(model_attributes) }

  describe 'class inheritance' do
    it 'binds contexts to the child classes' do
      person = PersonSerializer.new(Person.new(model_attributes), scope: { context: :show })
      user = UserSerializer.new(User.new(id: 2, name: 'test', email: 'test'), scope: { context: :show })

      expect(person.to_json).to eq(model_attributes.to_json)
      expect(user.to_json).to eq({id: 2, name: 'test', email: 'test'}.to_json)
    end
  end

  describe 'caching' do
    describe '.clear!' do
      it 'clears the cache' do
        PersonSerializer.new(Person.new(model_attributes))
        PersonSerializer.context_cache.clear!
        expect(PersonSerializer.context_cache.include? :default).to eq(false)
      end
    end

    context 'when a context has not been called' do
      it 'is not found in the cache' do
        expect(PersonSerializer.context_cache.include? :default).to eq(false)
      end
    end

    context 'when a context has been called' do
      it 'is registered in the cache' do
        PersonSerializer.new(Person.new(model_attributes))
        expect(PersonSerializer.context_cache.include? :default).to eq(true)
      end
    end
  end

  describe 'default context' do
    context 'when an empty serializer is defined' do
      it 'returns an empty hash' do
        expect(
          PersonSerializer.new(subject).to_json
        ).to eq({ id: subject.id }.to_json)
      end
    end
  end

  describe 'when a context is not defined' do
    it 'returns the default context' do
      expect(
        PersonSerializer.new(subject, scope: { context: :undefined }).to_json
      ).to eq({ id: subject.id }.to_json)
    end
  end

  describe 'explicit context' do
    context 'when a context is explicitly requests attributes' do
      it 'returns the defined attributes' do
        expect(
          PersonSerializer.new(subject, scope: { context: :show }).to_json
        ).to eq(model_attributes.to_json)
      end
    end

    context 'when a context value is specified' do
      it 'returns the defined attributes' do
        expect(
          PersonSerializer.new(subject, scope: { context: :list }).to_json
        ).to eq({ key: 1, value: 'Bender'}.to_json)
      end
    end

    context 'when a dynamic value is specified' do
      it 'returns the attribute' do
        expect(
          PersonSerializer.new(subject, scope: { context: :byline }).to_json
        ).to eq({ byline: "#{subject.name} says '#{subject.catch_phrase}'" }.to_json)
      end
    end
  end
end