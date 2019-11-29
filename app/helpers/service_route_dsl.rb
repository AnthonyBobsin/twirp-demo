module ServiceRouteDsl
  def mount_service(service_klass, handler_klass)
    srv = TwirpServiceBuilder.new(service_klass, handler_klass).build
    mount srv, at: srv.full_name
  end
end
