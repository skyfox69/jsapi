# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      def test_example
        response = Meta::Response.new
        Response.new(response).call { example value: 'foo' }
        assert_equal('foo', response.examples['default'].value)
      end

      # Link tests

      def test_link
        response = Meta::Response.new
        Response.new(response).call { link 'foo', operation_id: 'bar' }
        assert_equal('bar', response.link('foo').operation_id)
      end

      def test_link_with_block
        response = Meta::Response.new
        Response.new(response).call do
          link('foo') { operation_id 'bar' }
        end
        assert_equal('bar', response.link('foo').operation_id)
      end

      def test_link_reference
        response = Meta::Response.new
        Response.new(response).call { link ref: 'foo' }
        assert_equal('foo', response.link('foo').ref)
      end

      def test_link_reference_by_name
        response = Meta::Response.new
        Response.new(response).call { link 'foo' }
        assert_equal('foo', response.link('foo').ref)
      end

      def test_raises_an_exception_on_ambiguous_keywords
        response = Meta::Response.new
        error = assert_raises(Error) do
          Response.new(response).call do
            link ref: 'foo', operation_id: 'bar'
          end
        end
        assert_equal(
          'unsupported keyword: operation_id (at link)',
          error.message
        )
      end
    end
  end
end
