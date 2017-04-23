require 'singleton'
require 'influxdb'

module WeatherTS

  class InfluxdbDao
    include WeatherTS::Utils

    DB_NAME = 'chmi'

    def initialize
      client = InfluxDB::Client.new
      if client.list_databases.select {|db| db['name'] == DB_NAME}.empty?
        log.info "database does not exist => create"
        client.create_database DB_NAME
        client.create_retention_policy("6weeks.#{DB_NAME}", DB_NAME, '6w', 1, true)
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
