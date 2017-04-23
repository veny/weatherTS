require 'app'
require 'sinatra'

WeatherTS::logger = Logger.new(STDOUT)
WeatherTS::logger.level = Logger::DEBUG

WeatherTS::App.instance.build do
  service :dao,         WeatherTS::InfluxdbDao
  service :sniffer,     WeatherTS::IndexSniffer
  service :filter,      WeatherTS::DbFilter
  service :extractor,   WeatherTS::DownloadExtractor
  service :transformer, WeatherTS::PngTransformer
  service :loader,      WeatherTS::TsdbbLoader
end


get '/run' do
  'Hello world!'
  # WeatherTS::App.instance.run
end
