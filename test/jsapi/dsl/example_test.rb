# frozen_string_literal: true

module Jsapi
  module DSL
    module Concerns
      class ExamplesTest < Minitest::Test
        class Dummy < Node
          include Examples
        end

        def test_default_example
          model = define_model do
            example 'bar'
          end
          assert_equal('bar', model.example('default').value)
        end

        def test_example_with_options
          model = define_model do
            example value: 'bar'
          end
          assert_equal('bar', model.example('default').value)
        end

        def test_example_with_block
          model = define_model do
            example { value 'bar' }
          end
          assert_equal('bar', model.example('default').value)
        end

        def test_example_with_name_and_options
          model = define_model do
            example 'foo', value: 'bar'
          end
          assert_equal('bar', model.example('foo').value)
        end

        def test_example_with_name_and_block
          model = define_model do
            example 'foo' do
              value 'bar'
            end
          end
          assert_equal('bar', model.example('foo').value)
        end

        private

        def define_model(&block)
          Meta::Parameter.new('foo').tap do |model|
            Dummy.new(model, &block)
          end
        end
      end
    end
  end
end
