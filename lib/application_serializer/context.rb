module ApplicationSerializer
  module Context
    DEFAULT_CONTEXT_BLOCK = lambda { |_,_,_| [] }

    @contexts = {}

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

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :contexts

      def context(name, &block)
        @contexts[name] = block
      end

      def inherited(base)
        super
        base.contexts = {}
        base.contexts[::ApplicationSerializer::DEFAULT_CONTEXT] = ::ApplicationSerializer::Context::DEFAULT_CONTEXT_BLOCK
      end
    end
  end
end
