# frozen_string_literal: true

module ActionController
  class UnpermittedParameters < StandardError; end

  class Parameters < Hash
    def initialize(**args)
      super
      args.each { |key, value| self[key.to_s] = value }
    end

    def permit(*filters)
      raise UnpermittedParameters if (keys - filters.map(&:to_s)).any?

      self
    end
  end

  class API
  end
end
