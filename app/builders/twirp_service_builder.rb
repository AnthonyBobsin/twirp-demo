class TwirpServiceBuilder
  class << self
    def build(service_klass, handler_klass)
      builder = self.new
      builder.service_klass = service_klass
      builder.handler_klass = handler_klass
      builder.build
    end
  end

  attr_accessor :service_klass, :handler_klass

  def build
    validate_args!

    handler = handler_klass.new
    service = service_klass.new(handler_klass.new)

    # configure hooks
    service.before do |rack_env, env|
      # allow handler to be accessible for hooks
      env[:handler] = handler
    end
    handler_klass.before_hooks.each do |hook|
      service.before(&hook)
    end

    service.exception_raised do |e, env|
      Rails.logger.error e.backtrace.take(20).reverse.join("\n")
      Rails.logger.error e
    end

    service
  end

  private

  def validate_args!
    raise ArgumentError, "Missing service class" unless service_klass
    raise ArgumentError, "Missing handler class" unless handler_klass
  end
end