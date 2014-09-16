require 'thread'
require 'singleton'
require 'taglib'
require_relative './db.rb'
class WavHeadInfo
  include Singleton
  def setup(dir)
    @dir = dir ? dir : "#{Dir.home}/Music" # by default, use the user's music folder
    @dir = @dir +  "/" unless @dir[-1] == "/"
    self.parse_all
  end

  def parse_all
    @files = Dir.glob(@dir + "**/*")
    @files.each do |f|
      # Go through all files
      parse f
    end
  end
  def parse(f)
    info = get_info(f)

    artist = Artist.first_or_create(name: info[:artist])
    puts "Artist: #{artist.name}"
    album = Album.first_or_create(title: info[:album], artist: artist)
    puts "Album: #{album.title}"
    song = Song.new
    unless(Song.first(path: f) || Song.first(title: info[:title], length: info[:length], album: info[:album]))
      # If there's another song with the same name and same length,
      # this block is skipped. Otherwise, we make a new record for the song.
      song.attributes = {title: info[:title],
                         album: album,
                         path: f,
                         length: info[:length]}
      if song.save
        puts "Made a song: #{song.inspect}"
        puts ""
      else
        puts "Song could not be saved! #{song.inspect}"
        puts "Got errors: #{song.errors.inspect}"
      end
    end
  end

  def get_info(f)
    i = {}
    TagLib::FileRef.open(f) do |f|
      unless f.null?
        tag = f.tag
        prop = f.audio_properties
        i[:artist] = tag.artist
        i[:album] = tag.album
        i[:title] = tag.title
        i[:length] = prop.length
      end
    end
    return i
  end
end


