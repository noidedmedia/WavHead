require 'sinatra/base'
require_relative './db'
require_relative './wav_head_info.rb'
module WavHead
  class Server < Sinatra::Base
    def setup(options = {})
      @head = WavHead::Server.new
      set :port, options[:port] if options[:port]
      set :bind, '0.0.0.0'
    end
    get '/' do
      @artists = Artist.all
      erb :home
    end
    get "/browse/:artist" do
      @artist = Artist.first(name: params[:artist])
      erb :artist
    end
    get "/browse/:artist/:album" do
      @artist = Artist.first(name: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @songs = Song.all(album: @album)
      erb :album
    end
    get "/browse/:artist/:album/:song" do
      @artist = Artist.first(name: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @song = Song.first(title: params[:song], album: @album)
      erb :song
    end
    post "/browse/:artist/:album/:song/vote" do
      @artist = Artist.first(name: params[:artist])
      @album = Album.first(title: params[:album], artist: @artist)
      @song = Song.first(title: params[:song], album: @album)
      settings.p.vote(@song)
      redirect to("/")
    end

    get "/upnext" do
      @next = settings.p.next
      erb :upnext
    end
  end
end
