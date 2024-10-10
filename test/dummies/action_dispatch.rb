# frozen_string_literal: true

module ActionDispatch
  class Request
    attr_reader :headers

    def initialize(headers)
      @headers = headers
    end
  end

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
