# frozen_string_literal: true

module ActionController
  class Parameters < ActiveSupport::HashWithIndifferentAccess
    def permit(*filters)
      slice(*filters)
    end
  end

  class API; end
end
