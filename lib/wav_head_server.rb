require 'sinatra/base'
require 'json'
require_relative './db'
require_relative './wav_head_info.rb'
module WavHead
  class Server < Sinatra::Base
    configure do
      disable :logging
      enable :sessions
    end
    before do
      @queue = settings.p.top(25)
      @current = settings.p.current
      session[:uuid] = SecureRandom.uuid unless session[:uuid]
    end
    get '/queue' do
      erb :queue
    end
    get '/current.json' do
      content_type :json
      settings.p.current.to_json
    end
    get '/' do
      @artists = Artist.all(order: [:title.asc])
      erb :home
    end
    get "/browse/:artist" do
      @artist = Artist.first(safe_title: params[:artist])
      @albums = Album.all(artist: @artist, order: [:title.asc])
      erb :artist
    end
    get "/browse/:artist/:album" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      @songs = Song.all(album: @album, order: [:track.asc])
      erb :album
    end
    get "/browse/:artist/:album/:song" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      @song = Song.first(safe_title: params[:song], album: @album)
      erb :song
    end
    post "/browse/:artist/:album/:song/vote" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      @song = Song.first(safe_title: params[:song], album: @album)
      if settings.votemanager.can_vote?(session[:uuid], @song) then
        settings.votemanager.vote!(session[:uuid],@song)
        settings.p.vote(@song)
      end

      redirect back
    end
    get "/cover/:artist/:album" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      send_file @album.art_path if @album.art_path
    end
  end
end
