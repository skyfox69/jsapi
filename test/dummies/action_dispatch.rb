# frozen_string_literal: true

module ActionDispatch
  Response = Struct.new(:content_type, :body, :status, keyword_init: true)
end
