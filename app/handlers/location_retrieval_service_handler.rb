class LocationRetrievalServiceHandler < BaseHandler
  service_hooks do
    validate GetLocationsRequestValidator, if: :get_locations
    before :log_location, if: :get_locations
  end

  def get_locations(req, env)
    { locations: [{ id: 1, warehouse_id: 1, code: 'fake', address: '123 main st.' }] }
  end

  private

  def log_location(_rack_env, _env)
    puts "this location is dope"
  end
end
