module ServiceHandler
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      attr_accessor :hook_error

      define_callbacks :handle_rpc,
        terminator: -> (handler, result_lambda) do
          result = result_lambda.call
          if result.is_a?(Twirp::Error)
            handler.hook_error = result
            true
          end
        end,
        skip_after_callbacks_if_terminated: true
    end

    def handle_rpc
      run_callbacks(:handle_rpc) do
        yield
      end || hook_error
    end

    module ClassMethods
      def _normalize_callback_options(options)
        _normalize_callback_option(options, :only, :if)
        _normalize_callback_option(options, :except, :unless)
      end

      def _normalize_callback_option(options, from, to) # :nodoc:
        if from = options[from]
          _from = Array(from).map(&:to_s).to_set
          from = proc { |h| _from.include? h.rpc_method }
          options[to] = Array(options[to]).unshift(from)
        end
      end

      def _insert_callbacks(callbacks, block = nil)
        options = callbacks.extract_options!
        _normalize_callback_options(options)
        callbacks.push(block) if block
        callbacks.each do |callback|
          yield callback, options
        end
      end

      [:before, :after, :around].each do |callback|
        define_method "#{callback}_rpc" do |*names, &blk|
          _insert_callbacks(names, blk) do |name, options|
            set_callback(:handle_rpc, callback, name, options)
          end
        end

        define_method "prepend_#{callback}_rpc" do |*names, &blk|
          _insert_callbacks(names, blk) do |name, options|
            set_callback(:handle_rpc, callback, name, options.merge(prepend: true))
          end
        end

        define_method "skip_#{callback}_rpc" do |*names|
          _insert_callbacks(names) do |name, options|
            skip_callback(:handle_rpc, callback, name, options)
          end
        end
      end
    end
  end
end
