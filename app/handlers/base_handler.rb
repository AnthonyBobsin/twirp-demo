class BaseHandler
  extend ServiceHookDsl

  service_hooks do
    before :authenticate_user

    # NOTE:
    # possible functionality to add
    # - ensure handler is set in before
    # - error and rollbar (or should this be in service builder?)
    # - request store?
    # - stick to master
    # - InstacartCore::Owner
  end

  private

  def authenticate_user(_rack_env, env)
    # TODO: allow for configurable auth methods through initializer
    puts "you are very authenticated"
  end
end
