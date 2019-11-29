class BaseHandler
  extend ServiceHookDsl

  def self.inherited(base)
    # TODO: clean this up
    base.service_hooks do
      before :authenticate_user
    end
  end

  private

  def authenticate_user(_rack_env, env)
    puts "you are so goddamn authenticated"
  end
end
