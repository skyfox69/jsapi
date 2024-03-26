# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      class Version
        def self.from(version)
          return version if version.is_a?(Version)

          case version
          when '2.0', nil
            new(2, 0)
          when '3.0'
            new(3, 0)
          when '3.1'
            new(3, 1)
          else
            raise ArgumentError, "unsupported OpenAPI version: #{version.inspect}"
          end
        end

        attr_reader :major, :minor

        def initialize(major, minor)
          @major = major
          @minor = minor
        end

        def ==(other)
          other.is_a?(self.class) &&
            @major == other.major &&
            @minor == other.minor
        end

        def to_s
          "#{major}.#{minor}"
        end
      end
    end
  end
end
