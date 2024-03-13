# frozen_string_literal: true

module ActiveModel
  class Error
    attr_reader :attribute, :base, :options, :raw_type, :type

    def initialize(base, attribute, type = :invalid, **options)
      @base = base
      @attribute = attribute
      @raw_type = type
      @type = type || :invalid
      @options = options
    end

    def ==(other)
      other.is_a?(self.class) &&
        (other.base == @base) &&
        (other.attribute == @attribute) &&
        (other.raw_type == @raw_type) &&
        (other.options == @options)
    end

    def match?(attribute, type = nil, **options)
      return false if @attribute != attribute
      return false if type && (@type != type)

      options.each do |key, value|
        return false if @options[key] != value
      end
      true
    end

    def message
      return type unless type.is_a?(Symbol)

      I18n.t(type, scope: 'errors.messages', **options)
    end

    def strict_match?(attribute, type = nil, **options)
      (@attribute == attribute) &&
        (!type || @type == type) &&
        (@options == options)
    end
  end

  class Errors
    include Enumerable

    attr_reader :errors

    delegate :clear, :each, :empty?, :size, to: :errors

    def initialize(base = nil)
      @base = base
      @errors = []
      @context = []
    end

    def added?(attribute, type = :invalid, options = {})
      attribute, type = normalize_arguments(attribute, type, options)

      return messages_for(attribute).include?(type) unless type.is_a?(Symbol)

      errors.any? { |error| error.strict_match?(attribute, type, **options) }
    end

    def full_messages
      errors.map(&:full_message)
    end

    def full_messages_for(attribute)
      where(attribute).map(&:full_message)
    end

    def merge!(other)
      other.errors.each { |error| import(error) }
    end

    def messages_for(attribute)
      where(attribute).map(&:message)
    end

    def where(attribute, type = nil, **options)
      attribute, type = normalize_arguments(attribute, type, options)

      errors.select { |error| error.match?(attribute, type, **options) }
    end

    private

    def normalize_arguments(attribute, type, options)
      type = type.call(@base, options) if type.respond_to?(:call)

      [attribute.to_sym, type]
    end
  end

  class Name
    attr_reader :klass, :namespace

    def initialize(klass, namespace)
      @klass = klass
      @namespace = namespace
    end
  end

  module Naming
  end

  module Translation
  end

  module Validations
    extend ActiveSupport::Concern

    class_methods do
      def validate(*args)
        args.each { |arg| validations << arg }
      end

      def validations
        @validations ||= []
      end
    end

    alias read_attribute_for_validation send

    def valid?(_context = nil)
      errors.clear

      self.class.validations.each do |validation|
        send(validation)
      end
      errors.empty?
    end

    def invalid?(context = nil)
      !valid?(context)
    end
  end
end
