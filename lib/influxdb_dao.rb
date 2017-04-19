require 'singleton'
require 'influxdb'

module WeatherTS

  class InfluxdbDao
    include WeatherTS::Utils

    def initialize
      @db = InfluxDB::Client.new
      if @db.list_databases.select {|db| db['name'] == DB_NAME}.empty?
        log.info "database does not exist => create"
        @db.create_database DB_NAME
      end
      @db = InfluxDB::Client.new(DB_NAME, {udp: false})
    end

    def data_exist?(timestamp)
      influx_time = timestamp.strftime('%Y-%m-%d %H:%M:%S')
      query = "SELECT count(value) FROM z_max3d WHERE \"x\" = '1' and \"y\" = '1' and time = '#{influx_time}'"
      cnt = @db.query query
      !cnt.empty?
    end

    def insert(measurement, point)
      @db.write_point(measurement, point)
    end

  end

end
