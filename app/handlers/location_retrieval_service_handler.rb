class LocationRetrievalServiceHandler < BaseHandler
  def get_locations(req, env)
    { locations: [{ id: 1, warehouse_id: 1, code: 'fake', address: '123 main st.' }] }
  end
end
