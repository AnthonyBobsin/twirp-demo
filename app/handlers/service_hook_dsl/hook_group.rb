module ServiceHookDsl
  module HookGroup

    def service_hooks(&block)
      # TODO: set instance var to error out if hooks aren't within service_hooks block
      if block_given?
        @service_hooks = block
        instance_exec(&block)
      else
        @service_hooks
      end
    end

    def copy_service_hooks(from)
      return if from.service_hooks.nil?
      service_hooks(&from.service_hooks)
    end

    def inherited(base)
      super
      base.copy_service_hooks(self)
    end

  end
end