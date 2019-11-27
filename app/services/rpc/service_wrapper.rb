module Rpc
  class ServiceWrapper < SimpleDelegator
    # NOTE: deprecated, moving this functionality to handler
    extend ServiceDsl

    delegate :twirp_service_class, to: :class

    def initialize(handler)
      unless twirp_service_class.ancestors.include?(Twirp::Service)
        raise ArgumentError, "Should not inherit directly from ServiceWrapper without passing in a twirp service class. usage: < ServiceWrapper[Example::MyService]"
      end

      super(twirp_service_class.new(handler))
    end
  end
end
