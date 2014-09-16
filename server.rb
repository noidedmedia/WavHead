require 'sinatra/base'
require './db'
require_relative './wav_head.rb'
require_relative './wav_head_info.rb'
class Server < Sinatra::Base
  def setup
    @head = WavHead.new
  end
  get '/' do
    @artists = Artist.all
    erb :home
  end
  get "/media/:artist" do
    @artist = Artist.first(name: params[:artist])
    erb :artist
  end
  get "/media/:artist/:album" do
    @artist = Artist.first(name: params[:artist])
    @album = Album.first(title: params[:album], artist: @artist)
    @songs = Song.all(album: @album)
    erb :album
  end
  get "/media/:artist/:album/:song" do
    @artist = Artist.first(name: params[:artist])
    @album = Album.first(title: params[:album], artist: @artist)
    @song = Song.first(title: params[:song], album: @album)
    erb :song
  end
  post "/media/:artist/:album/:song/vote" do
    @artist = Artist.first(name: params[:artist])
    @album = Album.first(title: params[:album], artist: @artist)
    @song = Song.first(title: params[:song], album: @album)
    @head.vote(@song)
    redirect to("/")
  end

  get "/upnext" do
    @next = WavHead.instance.next
    erb :upnext
  end
end

WavHeadInfo.instance.setup(ARGV[0])
server.setup
Server.run!
