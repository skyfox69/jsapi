# frozen_string_literal: true

module Jsapi
  module Meta
    module Base
      module Attributes
        # Defines an attribute.
        def attribute(name, type = Object,
                      keys: nil,
                      values: nil,
                      default: nil,
                      default_key: nil,
                      writer: true)

          (@attribute_names ||= []) << name.to_sym

          instance_variable_name = "@#{name}"

          # Attribute reader
          define_method(name) do
            value = instance_variable_get(instance_variable_name)
            value.nil? ? default : value
          end

          case type
          when Array
            if writer
              singular_name = name.to_s.singularize
              type_caster = TypeCaster.new(type.first, values: values, name: singular_name)

              # Attribute writer
              define_method("#{name}=") do |argument|
                instance_variable_set(
                  instance_variable_name,
                  Array.wrap(argument).map { |element| type_caster.cast(element) }
                )
              end

              # add_{singular_name} method
              define_method("add_#{singular_name}") do |argument = nil|
                type_caster.cast(argument).tap do |casted_argument|
                  if instance_variable_defined?(instance_variable_name)
                    instance_variable_get(instance_variable_name)
                  else
                    instance_variable_set(instance_variable_name, [])
                  end << casted_argument
                end
              end
            end
          when Hash
            singular_name = name.to_s.singularize
            key_type, value_type = type.first
            key_type_caster = TypeCaster.new(key_type, values: keys, name: 'key')

            # hash value reader
            define_method(singular_name) do |key = nil|
              key = default_key if key.to_s.empty?
              send(name)&.[](key_type_caster.cast(key))
            end

            if writer
              value_type_caster = TypeCaster.new(value_type, values: values)

              # add_{singular_name} method
              define_method("add_#{singular_name}") do |key_or_value, value = nil|
                if value.nil? && default_key
                  key = default_key
                  value = key_or_value
                else
                  key = key_or_value
                  key = default_key if key.to_s.empty?
                end
                raise ArgumentError, "key can't be blank" if key.to_s.empty?

                casted_key = key_type_caster.cast(key)
                casted_value = value_type_caster.cast(value)

                if instance_variable_defined?(instance_variable_name)
                  instance_variable_get(instance_variable_name)
                else
                  instance_variable_set(instance_variable_name, {})
                end[casted_key] = casted_value
              end
            end
          else
            # Predicate method
            define_method("#{name}?") do
              value = instance_variable_get(instance_variable_name)
              value.nil? ? default || false : value
            end if values == [true, false]

            if writer
              type_caster = TypeCaster.new(type, values: values, name: name)

              # Attribute writer
              define_method("#{name}=") do |argument = nil|
                instance_variable_set(
                  instance_variable_name, type_caster.cast(argument)
                )
              end
            end
          end
        end

        def attribute_names
          names = @attribute_names || []
          return names unless superclass.respond_to?(:attribute_names)

          superclass.attribute_names + names
        end
      end
    end
  end
end
