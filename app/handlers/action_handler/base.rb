module ActionHandler
  class Base
    include ActionHandler::Callbacks
    include ActionHandler::Validation
  end
end
