module ApplicationSerializer
  class Base < ActiveModel::Serializer
    include ::ApplicationSerializer::Context

    def initialize(model, options = {})
      options = ::ApplicationSerializer::DEFAULT_OPTIONS.merge(options)
      requested_context = context_option(options[:scope])
      ctx = context_defined?(requested_context) ? requested_context : ::ApplicationSerializer::DEFAULT_CONTEXT

      get_context(ctx).call(self.class, options[:scope], model)

      super(model, options)
    end
  end
end
