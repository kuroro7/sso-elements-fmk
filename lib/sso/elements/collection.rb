require_relative 'config'

module SSO
  module Elements
    class Collection
      attr_accessor :version,
                    :signature,
                    :index,
                    :configs

      def initialize
        @addon_index = {}
        @lists = []
      end

      def table(name)
        index[name]
      end

      def build_index!
        @index = {}
        @configs.each do |config|
          config_name = config.name.split(' - ').last.downcase.split('_').map(&:capitalize).join('')
          @index[config_name] = config
        end
      end

      def load_elements!(path)
        sstat = [ 0, 0, 0, 0, 0 ]

        file = File.open(path, 'rb')

        @version = file.read(2).unpack('s<').first

        if @configs.nil?
          puts '[INFO] No config provided. Searching in default CFG files'
          if SSO::Elements::Config::CFG_AVAIL.keys.include?(@version)
            puts "[INFO] Using #{SSO::Elements::Config::CFG_AVAIL[@version]}!"
            load_config!(@version)
          else
            raise "[ERROR] No config provided and no default cfg file to match with elements version #{@version}!"
          end
        end

        @signature = file.read(2).unpack('s<').first

        @configs.each_with_index do |config, i|
          puts "[INFO] (#{i+1}/#{@configs.size}) Reading #{config.name} ... "
          sstat[0] = i

          if config.offset.size > 0
            config.offset = file.read(config.offset.size).bytes
          else
            puts 'CRITICAL: NO OFFSET FOUND!'
            return false
          end

          config.values = Array.new(read_value(file, 'int32'))
          sstat[1] = config.values.size

          (0...config.values.size).each do |e|
            config.values[e] = Array.new(config.types.size)

            (0...config.values[e].size).each do |f|
              config.values[e][f] = read_value(file, config.types[f])
            end
          end
        end

        file.close

        build_index!

        true
      end

      def load_config!(path)
        if path.is_a?(Integer)
          cfg = Config::CFG_AVAIL[path]
          raise "Incompatible version #{path}!" unless cfg
          dir = File.dirname(__FILE__)
          path = File.expand_path("./configs/#{cfg}", dir)
        end

        buffer = File.readlines(path, chomp: true)

        lists_size = buffer.shift.to_i

        lists = []
        @conversation_list_index = buffer.shift.to_i
        @conversation_list_index = 58 if @conversation_list_index == 0

        lists_size.times do
          line = ''

          loop do
            line = buffer.shift
            break unless line == ''
          end

          offset = buffer.shift

          list = Config.new
          list.name = line
          list.offset = Array.new(offset.to_i) if offset != 'AUTO'
          list.fields = buffer.shift.split(';')
          list.types = buffer.shift.split(';')
          lists << list
        end

        @configs = lists
        true
      end

      def load_rules(path)
        buffer = File.readlines(path, chomp: true)

        result = {}

        buffer.each do |line|
          next if line.empty? || line[0] == '#'

          if line.include?('|')
            key, value = line.split('|')
          else
            key = line
            value = ''
          end

          result[key] = value
        end

        result['SETCONVERSATIONLISTINDEX'] ||= 58

        result
      end

      def save!(path)
        File.delete(path) if File.exist?(path)
        file = File.open(path, 'wb')

        file.write([@version].pack('s<'))
        file.write([@signature].pack('s<'))

        @configs.each_with_index do |config, index|
          puts "[INFO] (#{index+1}/#{@configs.size}) Saving #{config.name} ... "
          file.write(config.offset.pack("C*")) if config.offset.size > 0

          if @conversation_list_index != index
            file.write([config.values.size].pack('l<'))
          end

          if config.elements_loaded?
            (0...config.values.size).each do |config_values_index|
              config.values[config_values_index] =  config.elements[config_values_index].to_value
            end
          end

          config.values.each do |values|
            values.each_with_index do |value, value_index|
              begin
                write_value(file, value, config.types[value_index])
              rescue => e
                pp values
                raise e
              end
            end
          end
        end

        file.close
        true
      rescue => e
        p e
        false
      end

      def read_value(file, type)
        if type == 'int16'
          file.read(2).unpack('s<')[0]
        elsif type == 'int32'
          file.read(4).unpack("l<")[0]
        elsif type == 'int64'
          file.read(8).unpack('q<')[0]
        elsif type == 'float'
          file.read(4).unpack('f')[0]
        elsif type == 'double'
          file.read(8).unpack('d')[0]
        elsif type.start_with?('byte:')
          byte_count = type[5..-1].to_i
          file.read(byte_count)
        elsif type.start_with?('wstring:')
          byte_count = type[8..-1].to_i
          Collection.compact_string(file.read(byte_count).force_encoding('UTF-16LE').encode('UTF-8'))
        elsif type.start_with?('string:')
          byte_count = type[7..-1].to_i
          Collection.compact_string(file.read(byte_count).force_encoding('UTF-8'))
        else
          nil
        end
      end

      def write_value(file, value, type)
        if type == 'int16'
          file.write([value.to_i].pack('s<'))
        elsif type == 'int32'
          file.write([value.to_i].pack('l<'))
        elsif type == 'int64'
          file.write([value.to_f].pack('q<'))
        elsif type == 'float'
          file.write([value.to_f].pack('f'))
        elsif type == 'double'
          file.write([value.to_f].pack('d'))
        elsif type.start_with?('byte:')
          file.write(value)
        elsif type.start_with?('wstring:')
          file.write(Collection.expand_string_utf16((value || 'BUG').encode('UTF-16LE'), type))
        elsif type.start_with?('string:')
          file.write(Collection.expand_string_utf8((value || 'BUG'), type))
        else
          nil
        end
      rescue => e
        pp value
        pp type
        raise e
      end

      def self.compact_string(s)
        s.gsub("\u0000", '')
      end

      def self.expand_string_utf16(base, type)
        sz = type.split(':').last.to_i
        s = base
        s += "\u0000".encode('UTF-16LE') while s.bytes.size < sz
        s
      end

      def self.expand_string_utf8(base, type)
        sz = type.split(':').last.to_i
        s = base
        s += "\u0000" while s.bytes.size < sz
        s
      end
    end
  end
end