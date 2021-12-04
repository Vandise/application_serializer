module ApplicationSerializer
  module Context
    DEFAULT_CONTEXT_BLOCK = lambda { |_,_,_| [] }

    @contexts = {}
    @context_cache = nil

    def context_option(scope)
      return scope.send(:context) if scope.respond_to? :context
      return scope.fetch(:context) if scope.respond_to? :fetch

      ::ApplicationSerializer::DEFAULT_CONTEXT
    end

    def context_defined?(ctx)
      self.class.contexts.key? ctx
    end

    def get_context(ctx)
      self.class.contexts[ctx]
    end

    def set_context_attributes(values)
      self.class._attributes_data = values
    end

    def load_context(model, options)
      requested_context = context_option(options[:scope])
      ctx = context_defined?(requested_context) ? requested_context : ::ApplicationSerializer::DEFAULT_CONTEXT

      if self.class.context_cache.include? ctx
        set_context_attributes(self.class.context_cache.get(ctx))
      else
        set_context_attributes({})
        get_context(ctx).call(self.class, options[:scope], model)
        self.class.context_cache.register(ctx, self.class._attributes_data)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :contexts, :context_cache

      def context(name, &block)
        @contexts[name] = block
      end

      def inherited(base)
        super
        base.context_cache = ::ApplicationSerializer::Cache.new
        base.contexts = {}
        base.contexts[::ApplicationSerializer::DEFAULT_CONTEXT] = ::ApplicationSerializer::Context::DEFAULT_CONTEXT_BLOCK
      end
    end
  end
end
