require 'data_mapper'
require 'raven'

class App < Sinatra::Base

  configure :production do
    require 'newrelic_rpm'

    Raven.configure do |config|
      config.dsn = ENV['SENTRY_URL']
    end

    use Raven::Rack
  end

  get '/' do
    @downloads = Download.all.group_by{ |d| d.url }.sort_by{|url, downloads| downloads.count }.reverse

    haml :index
  end

  get '/track.*' do
    is_valid = params[:url].match(/^http:\/\/media.evanwalsh.net(.*?\.mp3)/)

    if is_valid
      @download = Download.create(url: params[:url])

      redirect @download.url
    else
      redirect '/'
    end
  end

  get '/app.css' do
    sass :app
  end

  # Database stuff
  DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_OLIVE_URL'] || "sqlite://#{Dir.pwd}/my.db")

  class Download
    include DataMapper::Resource
    property :id, Serial
    property :url, String
    property :created_at, DateTime
  end

  DataMapper.finalize
  DataMapper.auto_upgrade!
end