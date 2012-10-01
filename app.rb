class App < Sinatra::Base
  CHECK_REGEX = /^http:\/\/media.evanwalsh.net(.*?\.mp3)/

  get '/' do
    @downloads = %w(One two THREE fOUR fIve)

    haml :index
  end

  get '/track.*' do
    is_valid = params[:url].match(CHECK_REGEX)

    if is_valid
      redirect params[:url]
    else
      redirect '/'
    end
  end

  get '/app.css' do
    sass :app
  end
end