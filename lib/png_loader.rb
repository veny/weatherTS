require 'chunky_png'

module WeatherTS

  class PngLoader
    include WeatherTS::Utils

    FILENAME = '/tmp/z_max3d.png'

    def exec
      data = context[:transformed]
      png = ChunkyPNG::Image.new(data[:pixels].size, data[:pixels][0].size)

      data[:pixels].each_with_index do |b, x|
        b.each_with_index do |val, y|
          png[x, y] = ChunkyPNG::Color(PngTransformer::COLORS.key(val))
        end
      end
      png.save(FILENAME)
      log.info "file saved, filepath=#{FILENAME}, resolution=#{png.width}x#{png.height}"
    end

  end

end
