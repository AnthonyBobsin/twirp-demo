class TwirpServiceBuilder
  attr_accessor :service_klass, :handler_klass

  def initialize(service_klass, handler_klass)
    @service_klass = service_klass
    @handler_klass = handler_klass
  end

  def build
    handler = handler_klass.new
    service = service_klass.new(handler_klass.new)

    # configure hooks
    if handler_klass.is_a?(ServiceHookDsl)
      # make handler instance accessible to hooks
      service.before { |_, env| env[:handler] = handler}

      # apply handler's configured service hooks
      handler_klass.configure_hooks(:before, service)
      handler_klass.configure_hooks(:on_success, service)
      handler_klass.configure_hooks(:on_error, service)
      handler_klass.configure_hooks(:exception_raised, service)
    end

    service.exception_raised do |e, env|
      Rails.logger.error e.backtrace.take(20).reverse.join("\n")
      Rails.logger.error e
    end

    service
  end
end