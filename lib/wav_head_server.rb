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
      @votes = []
@queue.each_with_index{|song,index|@votes[index]=settings.p.votes_for(song)}
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

    post "/browse/:artist/:album/:song/upvote" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      @song = Song.first(safe_title: params[:song], album: @album)
      if settings.votemanager.can_vote?(session[:uuid], @song) then
        settings.votemanager.vote!(session[:uuid],@song)
        #votemanager doesn't need to know if it's downvote or upvote. Only keeps time between votes
        settings.p.upvote(@song)
      end

      redirect back
    end

    post "/browse/:artist/:album/:song/downvote" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      @song = Song.first(safe_title: params[:song], album: @album)
      if settings.votemanager.can_vote?(session[:uuid], @song) then
        settings.votemanager.vote!(session[:uuid],@song)
        settings.p.downvote(@song)
      end

      redirect back
    end

    get "/cover/:artist/:album" do
      @artist = Artist.first(safe_title: params[:artist])
      @album = Album.first(safe_title: params[:album], artist: @artist)
      send_file @album.art_path if @album.art_path
      send_file File.dirname(File.expand_path(__FILE__)) + "/public/nocover.png"
    end
  end
end
