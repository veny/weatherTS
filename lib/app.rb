#!/usr/bin/env ruby

require 'singleton'
require 'logger'

# This module represents namespace of the tool.
module WeatherTS

  # Central logger.
  class << self
    attr_accessor :logger
  end

  DB_NAME = 'chmi'
  URL = 'http://portal.chmi.cz/files/portal/docs/meteo/rad/inca-cz/data/czrad-z_max3d/'

  autoload :InfluxdbDao,     'influxdb_dao'
  autoload :SimpleSniffer,   'simple_sniffer'
  autoload :LastFilter,      'last_filter'
  autoload :RandomFilter,    'random_filter'
  autoload :DbFilter,        'db_filter'
  autoload :SimpleExtractor, 'simple_extractor'
  autoload :PngTransformer,  'png_transformer'
  autoload :InfluxdbLoader,  'influxdb_loader'

  # You know: utilities...
  module Utils

    # Makes available the properly configured log for any client.
    def log
        log = WeatherTS::logger
        log.progname = self.class.name.split('::').last || ''
        return log
    end

    # Gets a context for the process based on thread local variable.
    def context
      Thread.current[:ctx] ||= {}
      Thread.current[:ctx]
    end

    def extract_time(filename)
      if matches = filename.match(/\.([0-9]+\.[0-9]+)\./)
        date = matches[1]
        t = Time.strptime(date, '%Y%m%d.%H%M') + Time.zone_offset('CEST') # the timestamp is already in UTC
        return t
      else
        raise 'failed to recognize timestamp in filename'
      end
    end

  end


  # This class represents the main application class and entry point.
  class App
    include ::Singleton
    include WeatherTS::Utils

    # Service Locator.
    def service(key, with = nil)
      @services ||= {}

      return @services[key.to_sym] if with.nil? # getter

      if with.is_a? Class
        @services[key.to_sym] = with.new # setter via constructor
      else
        @services[key.to_sym] = with # setter via object
      end
      log.debug "added service '#{key}'"
    end

    # Initializes all services that the engine depends on.
    def build(&block)
        # provide access to 'this' in configuration block
        self.instance_exec(&block)
    end

    # Runs the application.
    # This method represents a template method for the process.
    def run

      # Gets possible data source(s)
      service(:sniffer).exec

      # Filters the data source(s) to extract the relevant only.
      service(:filter).exec

      # ETL
      context[:to_be_extracted].each do |ds|
        context[:extract] = ds
        service(:extractor).exec
        service(:transformer).exec
        service(:loader).exec
      end

      log.info 'Bye bye'
    end

  end

end

#####################
# --== Bootstrap ==--

WeatherTS::logger = Logger.new(STDOUT)
WeatherTS::logger.level = Logger::INFO
WeatherTS::logger.level = Logger::DEBUG if __FILE__ == $0 # DEVELOPMENT MODE

WeatherTS::App.instance.build do
  service :dao,         WeatherTS::InfluxdbDao
  service :sniffer,     WeatherTS::SimpleSniffer
  service :filter,      WeatherTS::DbFilter
  service :extractor,   WeatherTS::SimpleExtractor
  service :transformer, WeatherTS::PngTransformer
  service :loader,      WeatherTS::InfluxdbLoader
end

WeatherTS::App.instance.run
