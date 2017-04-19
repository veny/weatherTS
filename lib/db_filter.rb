module WeatherTS

  class DbFilter
    include WeatherTS::Utils

    def exec
      context[:to_be_extracted] = []
      context[:data_source].each do |ds|
        timestamp = extract_time(ds)
        if App.instance.service(:dao).data_exist?(timestamp)
          log.info "filtered data source: existing timestamp=#{timestamp}, file=#{ds}"
        else
          context[:to_be_extracted] << ds
        end
      end
      log.info "filtered to #{context[:to_be_extracted].size} data source(s)"
      log.debug "to be extracted: #{context[:to_be_extracted]}"
context[:to_be_extracted] = [context[:data_source].last]
    end

  end

end
