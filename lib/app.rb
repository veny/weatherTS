#!/usr/bin/env ruby

require 'singleton'
require 'logger'

# This module represents namespace of the tool.
module WeatherTS

  # Central logger.
  class << self
    attr_accessor :logger
  end

  URL = 'http://portal.chmi.cz/files/portal/docs/meteo/rad/inca-cz/data/czrad-z_max3d/'

  autoload :SimpleSniffer,   'simple_sniffer'
  autoload :LastFilter,      'last_filter'
  autoload :RandomFilter,    'random_filter'
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
        return t.to_i
      else
        raise 'failed to recognize timestamp in filename'
      end
    end

  end


  # This class represents the main application class and entry point.
  class App
    include ::Singleton
    include WeatherTS::Utils

    attr_reader :sniffer
    attr_reader :filter
    attr_reader :extractor
    attr_reader :transformer
    attr_reader :loader

    ###
    # Constructor.
    def initialize
      @sniffer = new_sniffer
      @filter = new_filter
      @extractor = new_extractor
      @transformer = new_transformer
      @loader = new_loader
    end

    # Factory method to create a sniffer.
    def new_sniffer(with=SimpleSniffer)
      with.new
    end
    # Factory method to create a filter.
    def new_filter(with=LastFilter)
      with.new
    end
    # Factory method to create an extractor.
    def new_extractor(with=SimpleExtractor)
      with.new
    end
    # Factory method to create a transformer.
    def new_transformer(with=PngTransformer)
      with.new
    end
    # Factory method to create a loader.
    def new_loader(with=InfluxdbLoader)
      with.new
    end

    # Runs the application.
    # This method represents a template method for the process.
    def run

      # Gets possible data source(s).
      @sniffer.exec

      # Filters the data source(s) to extract the relevant only.
      @filter.exec
      log.info "filtered to #{context[:to_be_extracted].size} data source(s)"
      log.debug "to be extracted: #{context[:to_be_extracted]}"

      # ETL
      context[:to_be_extracted].each do |ds|
        context[:extract] = ds
        @extractor.exec
        @transformer.exec
        @loader.exec
      end

      log.info 'Bye bye'
    end

  end

end

WeatherTS::logger = Logger.new(STDOUT)
WeatherTS::logger.level = Logger::INFO
WeatherTS::logger.level = Logger::DEBUG if __FILE__ == $0 # DEVELOPMENT MODE
WeatherTS::App.instance.run

# require 'influxdb'
# db = InfluxDB::Client.new
# db.create_database('chmi')
# puts db.list_databases
