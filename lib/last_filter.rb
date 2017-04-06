require 'net/http'
require 'uri'

module WeatherTS

  class LastFilter
    include WeatherTS::Utils

    def exec
      context[:to_be_extracted] = [context[:data_source].last]
#      context[:to_be_extracted] = context[:data_source][0..10]
    end

  end

end
