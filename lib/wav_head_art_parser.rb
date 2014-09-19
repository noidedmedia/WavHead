require 'taglib'
require 'fileutils'
require 'base64'
require_relative './db.rb'
module WavHead
  ##
  # Grabs art for all files
  module ArtParser
    ART_PATH = "./.art_cache"
    def self.parse!
      FileUtils.mkdir_p(ART_PATH)
      self.parse_mpeg!
    end
    ##
    # Parse the cover art for all MP3s
    def self.parse_mpeg!
      Song.all(:path.like => "%.mp3").each do |s|
        # All songs that are MP3s
        a = s.album # Album for this song
        unless a.art_path # If we don't already have a cover for the album
          puts "Attempting to add cover art for #{a.title}..."
          TagLib::MPEG::File.open(s.path) do |f|
            # We try to grab a cover
            tag = f.id3v2_tag
            parse_id3(tag, a) # Parse unless it has the art already
          end
        end
      end
    end
    def self.parse_flac!
      Song.all(:path.like => "%.flac").each do |s|
        a = s.album
        unless a.art_path # if the art path isn't saved
          puts "Attempting to add cover art for #{a.title}"
          TagLib::FLAC::File.open(s.path) do |f|
            tag = f.id3v2_tag
            parse_id3(tag, a) unless a.art_path # Parse unless it has the art already
          end
        end
      end
    end
    # Parse an ID3 tag 
    def self.parse_id3(tag, a)
      cover = tag.frame_list('APIC').first
      unless cover.nil? # If there's a cover in the song...
        picture = cover.picture
        mime = cover.mime_type
        if picture && mime
          puts "Adding cover art to album #{a.title}..."
          save_for!(picture, mime, a)
        end
      end
    end

      # Save some data as the album cover
      def self.save_for!(data, mime, album)
        ext = get_ext(mime)
        # Path to save the file to
        path = "#{ART_PATH}/#{album.id}.#{ext}"
        puts "Saving cover for #{album.title} in #{path}"
        File.open(path, "w"){|f| f.write(data)}
        album.art_path = path
        album.save
      end
      # Convert a MIME-type into a file ext 
      def self.get_ext(m)
        case m
        when "image/jpg", "image/jpeg"
          return "jpg"
        when "image/gif"
          return "gif"
        when "image/png"
          return "png"
        end
      end
    end
  end

