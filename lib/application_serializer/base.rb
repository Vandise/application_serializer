module ApplicationSerializer
  class Base < ActiveModel::Serializer
    DEFAULT_CONTEXT = :default
    DEFAULT_OPTIONS = { context: DEFAULT_CONTEXT, scope: nil }

    class << self
      @@contexts = {}

      def context(ctx, &block)
        @@contexts[ctx] = block
      end
    end

    context DEFAULT_CONTEXT do |scope|
      []
    end

    def initialize(model, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      ctx = context_defined?(options[:context]) ? options[:context] : DEFAULT_CONTEXT
      attrs = get_context(ctx).call(options[:scope], self.class)

      self.class.attributes attrs.is_a?(Array) ? attrs : []

      super(model, options)
    end

    protected

    def context_defined?(ctx)
      @@contexts.key? ctx
    end

    def get_context(ctx)
      @@contexts[ctx]
    end
  end
end
