module ServiceRouteDsl
  def mount_service(service_klass, handler_klass)
    srv = TwirpServiceBuilder.build(service_klass, handler_klass)
    mount srv, at: srv.full_name
  end
end
