# frozen_string_literal: true

module ActionDispatch
  class Response
    attr_accessor :content_type, :status
    attr_writer :body

    def body
      return @body if defined? @body

      @stream.string if defined? @stream
    end

    def stream
      @stream ||= StringIO.new
    end
  end
end
