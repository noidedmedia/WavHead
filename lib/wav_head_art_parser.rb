require 'taglib'
require 'fileutils'
require 'base64'
require_relative './db.rb'
module WavHead
  ##
  # Grabs art for all songs in our DB
  module ArtParser
    ##
    # The place to store our art
    ART_PATH = "./.art_cache"
    ##
    # Parse all art for songs in the DB
    def self.parse!
      ##
      # Make the directory for the artwork cache if it doesn't exist
      FileUtils.mkdir_p(ART_PATH)
      ##
      # Parse MP3 files
      self.parse_mpeg!
      ##
      # Parse FLAC files
      self.parse_flac!
    end
    ##
    # Parse the cover art for all MP3s
    def self.parse_mpeg!
      ##
      # For each song that is an MP3
      Song.all(:path.like => "%.mp3").each do |s|
        a = s.album # Get the album
        unless a.art_path # If we don't already have a cover for the album
          puts "Attempting to add cover art for #{a.title}..."
          ##
          # Open the file and try to find art for it
          TagLib::MPEG::File.open(s.path) do |f|
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
      ## 
      # frame_list("APIC") is the art pic.
      # Use first since it can be an array.
      cover = tag.frame_list('APIC').first
      # We skip the next bit unless there's actually cover art
      unless cover.nil? 
        ## 
        # The data of the picture
        picture = cover.picture
        ##
        # The MIME type of the art
        mime = cover.mime_type
        if picture && mime
          ##
          # inform the user that we are saving the art.
          puts "Adding cover art to album #{a.title}..."
          ##
          # Save the art
          save_for!(picture, mime, a)
        end
      end
    end
      # Save some data as the album cover
      def self.save_for!(data, mime, album)
        ext = get_ext(mime)
        # Same the file as the id of the album + the extension in the 
        # ART_PATH directory
        path = "#{ART_PATH}/#{album.id}.#{ext}"
        puts "Saving cover for #{album.title} in #{path}"
        ##
        # Open the file and write the picture data
        File.open(path, "w"){|f| f.write(data)}
        ##
        # Set the art path on the file
        album.art_path = path
        ##
        # Save the album record
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

