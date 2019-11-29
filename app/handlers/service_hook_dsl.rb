module ServiceHookDsl
  extend ActiveSupport::Concern

  def service_hooks(&block)
    instance_exec(&block)
  end

  def validate(validator_klass, options = {})
    before lambda { |rack_env, env|
      validator = validator_klass.new(env[:input])
      return if validator.valid?

      validator.valid? || twirp_validation_error(validator.errors)
    }, **options, name: validator_klass.to_s
  end

  def before(method, options = {})
    @before_hooks ||= {}
    @before_hooks[options[:name] || method] = lambda do |rack_env, env|
      return if CallbackHelpers.skip?(env, options)
      instance_exec(&CallbackHelpers.make_execute_lambda(method, rack_env, env))
    end
  end

  def before_hooks
    # hashes are ordered by entry so this will
    # allow for override with different match filters
    @before_hooks.values
  end

  private

  def format_meta(meta)
    # Twirp::Error only accepts hash meta with string values
    meta.reduce({}) do |h, (k, v)|
      h[k] = v.is_a?(Array) ? v.to_sentence : v.to_s
      h
    end
  end

  def twirp_validation_error(errors)
    # NOTE: move to twirp error builder
    Twirp::Error.invalid_argument(
      'The request could not be understood by the server due to malformed syntax',
      format_meta(validator.errors.messages)
    )
  end

  module CallbackHelpers
    extend self

    def skip?(env, options)
      !match_if_filter?(env, options[:if]) ||
        match_unless_filter?(env, options[:unless])
    end

    def make_execute_lambda(method, rack_env, env)
      lambda do
        if method.is_a?(Proc)
          return method.call(rack_env, env)
        end

        handler = env[:handler]

        if handler.respond_to?(method, true)
          handler.send(method, rack_env, env)
        elsif respond_to?(method, true)
          send(method, rack_env, env)
        else
          raise NameError, "undefined method #{method}"
        end
      end
    end

    private

    def match_if_filter?(env, if_filter)
      return true if if_filter.nil?
      filter_inclusion?(env, if_filter)
    end

    def match_unless_filter?(env, unless_filter)
      return false if unless_filter.nil?
      filter_inclusion?(env, unless_filter)
    end

    def filter_inclusion?(env, filter)
      case filter
      when Symbol then filter == env[:ruby_method]
      when Array then filter.include?(env[[:ruby_method]])
      when Proc then filter.call(env)
      else
        raise ArgumentError, "unknown filter class received #{filter.class}"
      end
    end
  end
end
