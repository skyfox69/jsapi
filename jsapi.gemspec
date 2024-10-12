# frozen_string_literal: true

require_relative 'lib/jsapi/version'

Gem::Specification.new do |s|
  s.name = 'jsapi'
  s.version = Jsapi::Version::VERSION
  s.summary = 'Easily build OpenAPI compliant APIs with Rails.'
  s.license = 'MIT'
  s.authors = ['Denis Göller']
  s.email = 'denis@dmgoeller.de'
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'
  s.homepage = 'https://github.com/dmgoeller/jsapi'
  s.metadata = {
    'homepage_uri' => 'https://github.com/dmgoeller/jsapi'
  }
end
