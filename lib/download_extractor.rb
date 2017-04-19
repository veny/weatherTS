require 'open-uri'
require 'tmpdir'

module WeatherTS

  class DownloadExtractor
    include WeatherTS::Utils

    def exec
      ds = context[:extract]
      url = "#{CHMI::SITE_URL}/files/portal/docs/meteo/rad/inca-cz/data/czrad-z_max3d/#{ds}"
      tmpf = "#{Dir.tmpdir}#{File::SEPARATOR}#{ds}"
      IO.copy_stream(open(url), tmpf)
      log.info "extracted: #{tmpf}"
      context[:extracted] = tmpf
    end

  end

end
