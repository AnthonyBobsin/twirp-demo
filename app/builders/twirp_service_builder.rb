class TwirpServiceBuilder
  attr_accessor :service_klass, :handler

  def initialize(service_klass, handler)
    @service_klass = service_klass
    @handler = handler
  end

  def build
    service = service_klass.new(handler)

    # configure hooks
    if handler.class.is_a?(ServiceHookDsl)
      # make handler instance accessible to hooks
      service.before { |_, env| env[:handler] = handler}

      # apply handler's configured service hooks
      handler.class.configure_hooks(:before, service)
      handler.class.configure_hooks(:on_success, service)
      handler.class.configure_hooks(:on_error, service)
      handler.class.configure_hooks(:exception_raised, service)
    end

    service.exception_raised do |e, env|
      Rails.logger.error e.backtrace.take(20).reverse.join("\n")
      Rails.logger.error e
    end

    service
  end
end