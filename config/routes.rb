require 'rpc/demo/v1/locations_twirp'
require 'rpc/demo/v1/locations_pb'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  service = Demo::V1::LocationRetrievalService.new(LocationRetrievalServiceHandler.new)
  mount service, at: service.full_name
end
