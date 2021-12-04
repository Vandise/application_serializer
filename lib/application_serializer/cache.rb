module ApplicationSerializer
  class Cache
    def initialize
      @contexts = {}
    end

    def include?(context)
      @contexts.key? context
    end

    def get(context)
      @contexts[context]
    end

    def register(context, fields)
      @contexts[context] = fields
    end

    def clear!
      @contexts = {}
    end
  end
end