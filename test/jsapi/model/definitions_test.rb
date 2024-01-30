# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class DefinitionsTest < Minitest::Test
      def test_paths
        api_definitions = Definitions.new
        api_definitions.add_path('/foo', Path.new)

        assert_predicate(api_definitions.path('/foo'), :present?)
      end

      def test_minimal_openapi_document
        api_definitions = Definitions.new
        assert_equal({ openapi: '3.0.3' }, api_definitions.openapi_document)
      end
    end
  end
end
