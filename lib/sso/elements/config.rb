require_relative 'element'
require_relative 'field'

module SSO
  module Elements
    class Config
      attr_accessor :name,
                    :offset,
                    :type,
                    :fields,
                    :types,
                    :values

      CFG_AVAIL = {
        150 => 'PW_1.0.2_v150.cfg',
        152 => 'PW_1.0.2_v152.cfg'
      }

      def initialize
        @offsets = []
        @fields = []
        @types = []
        @values = []
      end

      def to_json
        values.map do |value|
          result = {}

          value.each_with_index do |data, index|
            result[fields[index]] = {
              'data' => data,
              'type' => types[index]
            }
          end

          result
        end
      end

      def elements
        return @elements if @elements

        @elements = values.map do |value|
          Element.from_value(self, value)
        end
      end

      def elements_loaded?
        !@elements.nil?
      end

      def add_element(element)
        @values << element.to_value
        @elements << element

        true
      end

      def find_element_by_id(id)
        elements.find do |element|
          element.id == id
        end
      end

      def find_element_by_name(name)
        elements.find do |element|
          element.name.to_s.downcase == name.to_s.downcase
        end
      end

      def find_elements_by_name(name)
        elements.select do |element|
          element.name.to_s.downcase.include?(name.to_s.downcase)
        end
      end
      def grouped_field_quantity
        return @fields_quantity if @fields_quantity

        @fields_quantity = {}

        fields.each do |field|
          @fields_quantity[field] ||= 0
          @fields_quantity[field]  += 1
        end

        @fields_quantity
      end
    end
  end
end