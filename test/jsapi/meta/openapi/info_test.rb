# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class InfoTest < Minitest::Test
        def test_contact
          info = Info.new
          info.contact = { name: 'Foo' }
          assert_equal('Foo', info.contact.name)
        end

        def test_license
          info = Info.new
          info.license = { name: 'Foo' }
          assert_equal('Foo', info.license.name)
        end

        def test_empty_info_object
          assert_equal({}, Info.new.to_h)
        end

        def test_full_info_object
          assert_equal(
            {
              title: 'Foo',
              description: 'Description of Foo',
              termsOfService: 'Terms of service',
              contact: {
                name: 'Bar'
              },
              license: {
                name: 'MIT'
              },
              version: '1'
            },
            Info.new(
              title: 'Foo',
              description: 'Description of Foo',
              terms_of_service: 'Terms of service',
              contact: {
                name: 'Bar'
              },
              license: {
                name: 'MIT'
              },
              version: 1
            ).to_h
          )
        end
      end
    end
  end
end
