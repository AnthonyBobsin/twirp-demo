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

    srv = service_klass.new(handler_klass.new)
    # add hooks and base instance behaviour
    srv
  end

  private

  def validate_args!
    raise ArgumentError, "Missing service class" unless service_klass
    raise ArgumentError, "Missing handler class" unless handler_klass
  end
end