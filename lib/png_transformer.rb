require 'chunky_png'

module WeatherTS

  class PngTransformer
    include WeatherTS::Utils

    # https://www.w3schools.com/colors/colors_picker.asp
    # http://portal.chmi.cz/files/portal/docs/meteo/rad/inca-cz/#
    @@colors = {
      # system colors
      '#000000' => 0, # black
      '#c4c4c4' => 0, # gray

      # business colors
      '#380070' => 4,  # lila
      '#3000a8' => 8,  # blue_dark
      '#0000fc' => 12, # blue
      '#006cc0' => 16, # blue_light
      '#00a000' => 20, # green_dark
      '#00bc00' => 24, # green
      '#34d800' => 28, # green_light
      '#9cdc00' => 32, # green_lighter
      '#e0dc00' => 36, # yellow
      '#fcb000' => 40, # orange_light
      '#fc8400' => 44, # orange
      '#fc5800' => 48, # orange_dark
      '#fc0000' => 52, # red
      '#a00000' => 56, # red_dark
      '#fcfcfc' => 60  # gray_light
    }
    
    def exec
      a = []
      context[:extracted].each do |file|
        log.info "processing file: #{file}"
        img = ChunkyPNG::Image.from_file file
        log.fatal "unknow image resolution: #{img.width}x#{img.height}" if img.width != 680 or img.height != 460
        (0..595).each do |x|
          a << []
          (100..409).each do |y|
            color = ChunkyPNG::Color.to_hex(img[x, y], false)
            log.fatal "unknown color: #{color}, x=#{x}, y=#{y}" unless @@colors.has_key? color
            a.last << @@colors[color]
          end
        end
      end
      context[:transformed] = a
    end

  end

end
