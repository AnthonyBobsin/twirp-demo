
# NOTE: move to initializer
require 'rpc/demo/v1/locations_twirp'
require 'rpc/demo/v1/locations_pb'

Rails.application.routes.draw do
  extend ServiceRouteDsl

  namespace :rpc do
    mount_service Demo::V1::LocationRetrievalService, LocationRetrievalServiceHandler
  end
end
