require 'data_mapper'
require 'raven'

class App < Sinatra::Base

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_URL']
  end

  use Raven::Rack

  configure :production do
    require 'newrelic_rpm'
  end

  get '/' do
    @downloads = Download.all.group_by{ |d| d.url }.sort_by{|url, downloads| downloads.count }.reverse

    haml :index
  end

  get '/track.*' do
    is_valid = params[:url].match(/^http:\/\/media.evanwalsh.net(.*?\.mp3)/)

    if is_valid
      @download = create_download_for_url(params[:url])

      redirect @download.url
    else
      redirect '/'
    end
  end

  get '/app.css' do
    sass :app
  end

  def create_download_for_url track_url
    download = Download.new(url: track_url)
    download.save

    download
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