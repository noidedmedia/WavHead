require 'sinatra/base'
require 'json'
require_relative './db'
require_relative './wav_head_info.rb'
module WavHead
  class Server < Sinatra::Base
    before do
      @queue = settings.p.top(10)
      @current = settings.p.current
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
      @artist = Artist.first(title: params[:artist])
      @albums = Album.all(artist: @artist, order: [:title.asc])
      erb :artist
    end
    get "/browse/:artist/:album" do
      @artist = Artist.first(title: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @songs = Song.all(album: @album, order: [:track.asc])
      erb :album
    end
    get "/browse/:artist/:album/:song" do
      @artist = Artist.first(title: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @song = Song.first(title: params[:song], album: @album)
      erb :song
    end
    post "/browse/:artist/:album/:song/vote" do
      @artist = Artist.first(title: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @song = Song.first(title: params[:song], album: @album)
      settings.p.vote(@song)
      redirect to("/")
    end
    get "/cover/:artist/:album" do
      @artist = Artist.first(title: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      send_file @album.art_path
    end
    get "/upnext" do
      @next = settings.p.next
      erb :upnext
    end
  end
end
