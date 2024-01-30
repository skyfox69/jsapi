# frozen_string_literal: true

module Jsapi
  module DSL
    class TestPath < Minitest::Test
      def test_operation
        path_model = Model::Path.new
        Path.new(path_model).call { operation :get, 'my_operation' }

        assert_equal(
          {
            'get' => {
              operationId: 'my_operation',
              deprecated: false,
              parameters: [],
              responses: {}
            }
          },
          path_model.to_openapi_path
        )
      end
    end
  end
end
