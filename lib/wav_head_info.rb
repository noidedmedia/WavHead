
require 'singleton'
require 'taglib'
require_relative './db'
module WavHead
  class Info
    include Singleton
    def delete!
      File.delete("./.db.sqlite")
    end
    def setup(d)
      dir = d.is_a?(String) ?  d : "#{Dir.home}/Music" # by default, use the user's music folder
      dir = dir +  "/" unless dir[-1] == "/"
      self.parse_all(dir)
    end

    def parse_all(dir)
      files = Dir.glob(dir + "**/*")
      files.each do |f|
        # Go through all files
        parse f unless File.directory?(f)
      end
    end
    def parse(f)
      info = get_info(f)
      artist = Artist.first_or_create(name: info[:artist])
      album = Album.first_or_create(title: info[:album], artist: artist)
      song = Song.new
      unless(Song.first(path: f) || Song.first(title: info[:title], length: info[:length], album: info[:album]))
        # If there's another song with the same name and same length,
        # this block is skipped. Otherwise, we make a new record for the song.
        song.attributes = {title: info[:title],
                           album: album,
                           path: f,
                           length: info[:length]}
        if song.save
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
    def pretty_print
      str = ""
      Artist.all.each do |a|
        str << "#{a.name}\n"
        a.albums.each do |a|
          str << "\t#{a.title}\n"
          a.songs.each do |s|
            time_str = Time.at(s.length).utc.strftime("%H:%M:%S")
            str << "\t\t #{s.title} (#{time_str})\n"
          end
          str << "\n"
        end
        str << "\n\s"
      end
      return str
    end
  end
end

