module Rpc
  class ServiceWrapper < SimpleDelegator
    extend ServiceDsl

    class << self
      def [](service_class)
        klass = Class.new(self)
        klass.twirp_service_class = service_class
        klass
      end

      def inherited(subclass)
        subclass.twirp_service_class = twirp_service_class
      end
    end

    def initialize(handler)
      super(self.class.twirp_service_class.new(handler))
    end
  end
end
