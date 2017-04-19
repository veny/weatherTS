module WeatherTS

  class InfluxdbLoader
    include WeatherTS::Utils

    def exec
      data = context[:transformed]
      data[:pixels].each_with_index do |b, x|
        b.each_with_index do |val, y|
          point = { tags: {}, values: {}, timestamp: data[:timestamp] }
          point[:tags][:x] = x
          point[:tags][:y] = y
        #   point[:values][:x] = x
        #   point[:values][:y] = y
          point[:values][:value] = "#{val}i" # write as integer
        #   if x % 10 == 0
            print "\r"
            # print "progress: #{x / 10} %"
            print "progress: #{x} % | #{point}"
            $stdout.flush
          App.instance.service(:dao).insert('z_max3d', point) #if x == 0 and y == 0
        end
      end
    end

  end

end
