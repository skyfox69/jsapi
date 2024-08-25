# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ParametersInvalidTest < Minitest::Test
      def test_errors
        errors = [Model::Error.new(nil, :foo, :invalid)]

        Model::Errors.stub_any_instance(:errors, errors) do
          error = ParametersInvalid.new(Model::Base.new({}))
          assert_equal(errors, error.errors)
        end
      end

      def test_message
        Model::Errors.stub_any_instance(:full_messages, %w[foo]) do
          error = ParametersInvalid.new(Model::Base.new({}))
          assert_equal('foo.', error.message)
        end

        Model::Errors.stub_any_instance(:full_messages, %w[foo bar]) do
          error = ParametersInvalid.new(Model::Base.new({}))
          assert_equal('foo. bar.', error.message)
        end

        Model::Errors.stub_any_instance(:full_messages, %w[foo. bar.]) do
          error = ParametersInvalid.new(Model::Base.new({}))
          assert_equal('foo. bar.', error.message)
        end
      end
    end
  end
end
