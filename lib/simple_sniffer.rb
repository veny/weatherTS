require 'net/http'
require 'uri'

module WeatherTS

  # czrad-z_max3d/ ?
  class SimpleSniffer
    include WeatherTS::Utils

    # Each link represents an URL where the data can be downloaded.
    def exec
      uri = URI.parse('http://portal.chmi.cz/files/portal/docs/meteo/rad/inca-cz/data/czrad-z_max3d/')
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      html = response.body

      rslt = []
      pattern = /<a href=[\'"]?([^\'"> ]*)[\'"]?[^>]*>(.*?)<\/a>/o
      html.gsub!(pattern) do |n|
        file = $1
        rslt << file if file =~ /png$/
      end
      log.info "found #{rslt.size} data source(s)"
      context[:data_source] = rslt
    end

  end

end
