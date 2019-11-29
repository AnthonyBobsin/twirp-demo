class LocationRetrievalServiceHandlerV2 < ApplicationHandler
  # TODO: metaprogram this away (class method and process_action wrap in get_locations)

  use_validator GetLocationsRequestValidator, only: :get_locations

  def self.get_locations(req, env)
    new(req, env).get_locations
  end

  def get_locations
    process_action do
      { locations: [{ id: 1, warehouse_id: 1, code: 'fake', address: '123 main st.' }] }
    end
  end
end
