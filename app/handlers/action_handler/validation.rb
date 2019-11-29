module ActionHandler
  module Validation
    extend ActiveSupport::Concern

    module ClassMethods
      def use_validator(validator_klass, **opts)
        unless validator_klass.include?(ActiveModel::Validations)
          raise ArgumentError, "validator class should include ActiveModel::Validations"
        end

        before_action **opts do
          validator = validator_klass.new(env[:input])
          validator.valid?
          validator.valid? || twirp_validation_error(validator.errors)
        end
      end
    end

    # TODO: move to twirp error builder

    def twirp_validation_error(errors)
      Twirp::Error.invalid_argument(
        'The request could not be understood by the server due to malformed syntax',
        format_meta(errors.messages)
      )
    end

    private

    def format_meta(meta)
      # Twirp::Error only accepts hash meta with string values
      meta.reduce({}) do |h, (k, v)|
        h[k] = v.is_a?(Array) ? v.to_sentence : v.to_s
        h
      end
    end
  end
end