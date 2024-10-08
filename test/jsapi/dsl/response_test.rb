# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      # #example

      def test_example
        response = define_response { example 'foo' }
        assert_equal('foo', response.example('default').value)
      end

      # #link

      def test_link
        response = define_response do
          link 'foo', operation_id: 'bar'
        end
        assert_equal('bar', response.link('foo').operation_id)
      end

      def test_link_with_block
        response = define_response do
          link('foo') { operation_id 'bar' }
        end
        assert_equal('bar', response.link('foo').operation_id)
      end

      def test_link_reference
        response = define_response do
          link ref: 'foo'
        end
        assert_equal('foo', response.link('foo').ref)
      end

      def test_link_reference_by_name
        response = define_response do
          link 'foo'
        end
        assert_equal('foo', response.link('foo').ref)
      end

      def test_raises_an_exception_on_ambiguous_keywords
        error = assert_raises(Error) do
          define_response do
            link ref: 'foo', operation_id: 'bar'
          end
        end
        assert_equal('unsupported keyword: operation_id (at link)', error.message)
      end

      private

      def define_response(**keywords, &block)
        Meta::Response.new(keywords).tap do |response|
          Response.new(response, &block)
        end
      end
    end
  end
end
