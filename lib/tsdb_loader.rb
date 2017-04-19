module WeatherTS

  class TsdbbLoader
    include WeatherTS::Utils

    def exec
      data = context[:transformed]
      log.info "loading data matrix #{data[:pixels].size}x#{data[:pixels][0].size}, timestamp=#{data[:timestamp]}"
      data[:pixels].each_with_index do |b, x|
        b.each_with_index do |val, y|
          point = { tags: {}, values: {}, timestamp: data[:timestamp] }
          point[:tags][:x] = x
          point[:tags][:y] = y
          point[:values][:value] = val

          # progress
          print "\r"
          print "progress: #{x * 100 / data[:pixels].size} %"
          $stdout.flush
          App.instance.service(:dao).insert('z_max3d', point) #if x == 0 and y == 0
        end
      end
      print "\r"
    end

  end

end
