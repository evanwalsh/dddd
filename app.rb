require 'data_mapper'

class App < Sinatra::Base
  CHECK_REGEX = /^http:\/\/media.evanwalsh.net(.*?\.mp3)/

  get '/' do
    @downloads = Download.all.group_by{ |d| d.url }.sort_by{|url, downloads| downloads.count }.reverse

    haml :index
  end

  get '/track.*' do
    is_valid = params[:url].match(CHECK_REGEX)

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