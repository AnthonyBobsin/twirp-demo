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
    # ServiceHookDsl provided handler hooks
    if handler_klass.respond_to?(:configure_hooks)
      service.before do |rack_env, env|
        # allow handler to be accessible for hooks
        env[:handler] = handler
      end

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