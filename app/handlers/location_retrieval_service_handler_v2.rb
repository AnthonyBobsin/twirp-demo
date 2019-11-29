class LocationRetrievalServiceHandlerV2 < ApplicationHandler
  before_rpc :log_location
  validate_input :get_locations, with: GetLocationsRequestValidator

  # TODO: metaprogram this away (class method and process_action wrap in get_locations)
  # problems
  # - how would initializer's signature look? req can be different for each rpc method
  # -
  def self.get_locations(req, env)
    new(req, env).get_locations
  end

  def get_locations
    handle_rpc do
      { locations: [{ id: 1, warehouse_id: 1, code: 'fake', address: '123 main st.' }] }
    end
  end

  def log_location
    puts "log location"
  end
end
