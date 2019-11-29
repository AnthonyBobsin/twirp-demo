module ServiceRouteDsl
  def mount_service(service_klass, handler)
    srv = TwirpServiceBuilder.new(service_klass, handler).build
    mount srv, at: srv.full_name
  end
end
