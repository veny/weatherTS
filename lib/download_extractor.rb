require 'open-uri'
require 'tmpdir'

module WeatherTS

  class DownloadExtractor
    include WeatherTS::Utils

    def exec
      ds = context[:extract]
      url = "#{URL}#{ds}"
      tmpf = "#{Dir.tmpdir}#{File::SEPARATOR}#{ds}"
      IO.copy_stream(open(url), tmpf)
      log.info "extracted: #{tmpf}"
      context[:extracted] = tmpf
    end

  end

end
