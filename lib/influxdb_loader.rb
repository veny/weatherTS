require 'influxdb'

module WeatherTS

  class InfluxdbLoader
    include WeatherTS::Utils

    def initialize
        @db = InfluxDB::Client.new 'chmi'
        #influxdb.create_database('chmi')
    end

    def exec
      a = context[:transformed]
      a.each_with_index do |b, x|
        b.each_with_index do |val, y|
          data = { tags: {}, values: {} }
          data[:tags][:x] = x
          data[:tags][:y] = y
          data[:values][:value] = val # TODO as integer
puts data
        end
      end

    #   data = {
    #     tags:   { name: 'pacz2gmaps3.z_max3d.20170403.0730.0.png' },
    #     values: {}
    #   }
    #   1.upto(2) do |i|
    #     1.upto(2) do |j|
    #       data[:tags][:r] = i
    #       data[:tags][:c] = j
    #       data[:values][:value] = rand(100)
    #   #influxdb.write_point('rain', data)
    #     end
    #   end
    end

  end

end
