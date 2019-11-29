module ServiceHandler
  class Base
    include ServiceHandler::Callbacks
    include ServiceHandler::Validation
  end
end
