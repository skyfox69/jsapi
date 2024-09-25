# frozen_string_literal: true

class EchoController < Jsapi::Controller::Base
  api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400

  api_operation path: '/echo' do
    parameter 'call', type: 'string', existence: true
    response 200, type: 'object' do
      property 'echo', type: 'string'
    end
    response 400, type: 'object' do
      property 'status', type: 'integer'
      property 'message', type: 'string'
    end
  end

  openapi do
    info title: 'Echo', version: '1'
  end

  def index
    api_operation! status: 200 do |api_params|
      {
        echo: "#{api_params.call}, again"
      }
    end
  end

  def openapi
    render(json: api_definitions.openapi_document(params[:version]))
  end
end
