module SSO
  module Elements
    class Element
      attr_accessor :fields

      def initialize
        @fields = {}
      end

      def set_field(index, field)
        @fields[index] = field

        return if index == 'ID'
        return if index == 'Name'

        define_singleton_method(index) {@fields[index].value }
        define_singleton_method("#{index}=") { |value| @fields[index].value = value }
      end

      def set_multi_field(index, field)
        @fields[index] ||= []
        @fields[index] << field

        define_singleton_method(index) {@fields[index] }
      end

      def clone
        element = Element.new
        element.fields = {}

        @fields.each do |name, field|
          element.set_field(name, Field.new(field.type, field.value, field.index))
        end

        element
      end

      def field_names
        @fields.keys
      end

      def [](index)
        @fields[index].value
      end

      def []=(index, value)
        @fields[index].value = value
      end

      def compact
        result = {}

        @fields.each do |name, field|
          result[name] = field.value
        end

        result
      end

      def id
        @fields['ID'].value
      end

      def id=(value)
        @fields['ID'].value = value
      end

      def name
        @fields['Name'].value
      end

      def name=(value)
        @fields['Name'].value = value
      end

      def to_value
        value = []

        self.fields.values.each do |field|
          if field.is_a?(Array)
            field.each do |f|
              value[f.index] = f.value
            end

            next
          end

          value[field.index] = field.value
        end

        value
      end

      def self.from_value(config, value)
        element = Element.new

        value.each_with_index do |data, index|
          field = config.fields[index]
          type = config.types[index]

          if config.grouped_field_quantity[field] <= 1
            element.set_field(field, Field.new(type, data, index))
          else
            element.set_multi_field(field, Field.new(type, data, index))
          end
        end

        element
      end
    end
  end
end