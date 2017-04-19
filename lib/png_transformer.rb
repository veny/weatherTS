require 'chunky_png'

module WeatherTS

  class PngTransformer
    include WeatherTS::Utils

    # https://www.w3schools.com/colors/colors_picker.asp
    # http://portal.chmi.cz/files/portal/docs/meteo/rad/inca-cz/#
    COLORS = {
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
      rslt = { timestamp: nil, pixels: [] }
      file = context[:extracted] # e.g. /tmp/pacz2gmaps3.z_max3d.20170406.0850.0.png
      log.info "processing file: #{file}"
      rslt[:timestamp] = extract_time(file).to_i

      img = ChunkyPNG::Image.from_file file
      log.fatal "unknow image resolution: #{img.width}x#{img.height}" if img.width != 680 or img.height != 460
      CHMI::PNG_X_RANGE.step(CHMI::AGGREGATION_STEP) do |x|
        rslt[:pixels] << []
        CHMI::PNG_Y_RANGE.step(CHMI::AGGREGATION_STEP) do |y|
          sum = cnt = 0
          (0..CHMI::AGGREGATION_STEP-1).each do |inc_x|
            (0..CHMI::AGGREGATION_STEP-1).each do |inc_y|
              color = ChunkyPNG::Color.to_hex(img[x+inc_x, y+inc_y], false)
              log.fatal "unknown color: #{color}, x=#{x}, y=#{y}" unless COLORS.has_key? color
              sum += COLORS[color]
              cnt += 1
            end
          end
          # round to the nearest multiple of '4'
          rslt[:pixels].last << (sum.to_f / cnt / 4).round * 4
        end
      end
      context[:transformed] = rslt
    end

  end

end
