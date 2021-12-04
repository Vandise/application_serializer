module ApplicationSerializer
  class Base < ActiveModel::Serializer
    include ::ApplicationSerializer::Context

    def initialize(model, options = {})
      load_context(model, ::ApplicationSerializer::DEFAULT_OPTIONS.merge(options))
      super(model, options)
    end
  end
end
