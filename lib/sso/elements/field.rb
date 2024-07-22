module SSO
  module Elements
    class Field
      attr_accessor :type,
                    :value,
                    :index

      def initialize(type, value, index)
        @type = type
        @value = value
        @index = index
      end

      def compact
        {
          type: @type,
          value: @value
        }
      end
    end
  end
end