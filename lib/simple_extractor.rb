require 'open-uri'
require 'tmpdir'

module WeatherTS

  # DownloadExtractor?
  class SimpleExtractor
    include WeatherTS::Utils

    def exec
      context[:extracted] = []
      context[:to_be_extracted].each do |ds|
        url = "#{URL}#{ds}"
        tmpf = "#{Dir.tmpdir}#{File::SEPARATOR}#{ds}"
        IO.copy_stream(open(url), tmpf)
        App.instance.log.info "extracted: #{tmpf}"
        context[:extracted] << tmpf
      end
    end

  end

end
