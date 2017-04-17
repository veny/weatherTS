require 'influxdb'

module WeatherTS

  class InfluxdbLoader
    include WeatherTS::Utils

    def initialize
        @db = InfluxDB::Client.new 'chmi'
        #influxdb.create_database('chmi')
    end

    def exec
      data = context[:transformed]
      data[:pixels].each_with_index do |b, x|
        b.each_with_index do |val, y|
          point = { tags: {}, values: {}, timestamp: data[:timestamp] }
          point[:tags][:x] = x
          point[:tags][:y] = y
          point[:values][:value] = "#{val}i" # write as integer
puts "XXXXXXXXXXXXXXx #{point}" if x == 0 and y == 0
          @db.write_point('z_max3d', point) if x == 0 and y == 0
        end
      end
    end

  end

end
