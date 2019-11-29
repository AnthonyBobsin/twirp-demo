module ServiceHookDsl
  extend ActiveSupport::Concern

  VALID_HOOKS = [:before, :on_success, :on_error, :exception_raised]

  def service_hooks(&block)
    # TODO: set instance var to error out if hooks aren't within service_hooks block
    instance_exec(&block)
  end

  VALID_HOOKS.each do |hook|
    # hook configuration methods for all supported twirp hooks
    #
    # usage:
    # service_hooks do
    #   before :authenticate_user, except: :create_user
    #   exception_raised, :log_internal_error
    # end
    define_method hook do |method, options = {}|
      hook_var_name = "@#{hook}_hooks"
      existing_hooks = instance_variable_get(hook_var_name)
      if existing_hooks.nil?
        existing_hooks = {}
        instance_variable_set(hook_var_name, existing_hooks)
      end

      define_hook(existing_hooks, method, options)
    end
  end

  def validate_input(validator_klass, options = {})
    before lambda { |rack_env, env|
      validator = validator_klass.new(env[:input])
      validator.valid? || twirp_validation_error(validator.errors)
    }, **options, name: validator_klass.to_s
  end

  def configure_hooks(hook_type, service)
    unless VALID_HOOKS.include?(hook_type)
      raise ArgumentError, "unknown twirp hook type received: #{hook_type}"
    end

    existing_hooks = instance_variable_get("@#{hook_type}_hooks")
    return if existing_hooks.nil?

    existing_hooks.values.each do |hook|
      service.send(hook_type, &hook)
    end
  end

  private

  def define_hook(hooks, method, options)
    hook_name = options[:name] || method
    if hook_name.is_a?(Proc)
      raise ArgumentError, "name option required when using proc for method"
    end

    hooks[hook_name] = lambda do |*args|
      env = args.find { |arg| arg.is_a?(Hash) && arg.key?(:input) }
      return if CallbackHelpers.skip?(env, options)
      instance_exec(&CallbackHelpers.make_execute_lambda(method, env[:handler], *args))
    end
  end

  def format_meta(meta)
    # Twirp::Error only accepts hash meta with string values
    meta.reduce({}) do |h, (k, v)|
      h[k] = v.is_a?(Array) ? v.to_sentence : v.to_s
      h
    end
  end

  def twirp_validation_error(errors)
    # TODO: move to twirp error builder
    Twirp::Error.invalid_argument(
      'The request could not be understood by the server due to malformed syntax',
      format_meta(errors.messages)
    )
  end

  module CallbackHelpers
    extend self

    def skip?(env, options)
      !match_if_filter?(env, options[:if]) ||
        match_unless_filter?(env, options[:unless])
    end

    def make_execute_lambda(method, handler, *args)
      lambda do
        if method.is_a?(Proc)
          return method.call(*args)
        end

        if handler.respond_to?(method, true)
          handler.send(method, *args)
        elsif respond_to?(method, true)
          send(method, *args)
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
