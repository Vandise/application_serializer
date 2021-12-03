module ApplicationSerializer
  class Base < ActiveModel::Serializer
    DEFAULT_CONTEXT = :default
    DEFAULT_OPTIONS = { scope: nil }

    class << self
      @@contexts = {}
      def context(ctx, &block)
        @@contexts[ctx] = block
      end
    end

    context DEFAULT_CONTEXT do |serialize,scope|
      serialize.attributes []
    end

    def initialize(model, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      requested_context = context_option(options[:scope])
      ctx = context_defined?(requested_context) ? requested_context : DEFAULT_CONTEXT
      attrs = get_context(ctx).call(self.class, options[:scope], model)

      super(model, options)
    end

    protected

    def context_option(scope)
      return scope.send(:context) if scope.respond_to? :context
      return scope.fetch(:context) if scope.respond_to? :fetch

      DEFAULT_CONTEXT
    end

    def context_defined?(ctx)
      @@contexts.key? ctx
    end

    def get_context(ctx)
      @@contexts[ctx]
    end
  end
end
