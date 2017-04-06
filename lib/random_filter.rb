require 'net/http'
require 'uri'

module WeatherTS

  class RandomFilter
    include WeatherTS::Utils

    def exec
      context[:to_be_extracted] = context[:data_source].sample 3
    end

  end

end
