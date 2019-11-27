module Rpc
  module ServiceDsl
    attr_accessor :twirp_service_class, :before,
                  :on_success, :on_error, :exception_raised

    def [](service_class)
      klass = Class.new(self)
      klass.twirp_service_class = service_class
      klass
    end

    def inherited(subclass)
      subclass.twirp_service_class = twirp_service_class
    end

    # NOTE: how to handle before hooks per method?
    # can add if lambda that accepts env with/or rpc method
    def before(&block)
      @before ||= []
      @before << block
    end

    def on_success(&block)
      @on_success ||= []
      @on_success << block
    end

    def on_error(&block)
      @on_error ||= []
      @on_error << block
    end

    def exception_raised(&block)
      @exception_raised ||= []
      @exception_raised << block
    end
  end
end
