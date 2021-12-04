module ApplicationSerializer

  DEFAULT_CONTEXT_BLOCK = lambda { |_,_,_| [] }

  class Base < ActiveModel::Serializer
    DEFAULT_CONTEXT = :default
    DEFAULT_OPTIONS = { scope: nil }

    @contexts = {}

    class << self
      attr_accessor :contexts
    end

    def self.context(name, &block)
      @contexts[name] = block
    end

    def self.inherited(base)
      super
      base.contexts = {}
      base.contexts[DEFAULT_CONTEXT] = ApplicationSerializer::DEFAULT_CONTEXT_BLOCK
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
      self.class.contexts.key? ctx
    end

    def get_context(ctx)
      self.class.contexts[ctx]
    end
  end
end
