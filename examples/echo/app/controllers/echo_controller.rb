# frozen_string_literal: true

class EchoController < Jsapi::Controller::Base
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
