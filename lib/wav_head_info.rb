require 'taglib'
require_relative './db'
require_relative './wav_head_art_parser'
module WavHead
  ##
  # This module provides information about songs.
  # It may also create information for songs.
  # The info is sorted as an SQLite DB for ease of access.
  module Info
    ## 
    # Delete all info.
    def self.delete!
      File.delete("./.db.sqlite")
    end
    ## 
    # Set up our DB with info from a directory.
    def self.setup(d)
      dir = d.is_a?(String) ? d : "#{Dir.home}/Music" # by default, use the user's music folder
      # Need the path to end with a /, so we add one if it doesn't.
      dir = dir +  "/" unless dir[-1] == "/"
      puts "Indexing #{dir}"
      ##
      # Parse everything in the directory.
      self.parse_all(dir)
    end

    def self.parse_all(dir)
      files = Dir.glob(dir + "**/*")
      ## 
      # Go through every file in the directory, as well as files in
      # sub-directories
      files.each do |f|
        # Go through all files
        parse f unless File.directory?(f)
      end
      ## 
      # Album art is parsed by another module.
      WavHead::ArtParser.parse!
    end
    def self.parse(f)
      info = get_info(f) # Retrieve the info
      # Create an artist from the info, or find one if it exists.
      # Thus, unless we can find an album with the name, we make a new one.
      # (Would use first_or_create if my frontend guy didn't complain about his
      # poorly-tagged music not working :L)
      unless artist = Artist.find(condition: ["lower(title) = ?", info[:artist]]).first then
        artist = Artist.create(title: info[:artist])
      end

      # Do the same for an album
      album = Album.first_or_create(title: info[:album], artist: artist)
      # Create a new song
      song = Song.new
      # Unless we have the song indexed already, or a song with the same title
      # and length...
      unless(Song.first(path: f) || Song.first(title: info[:title], length: info[:length], album: info[:album]))
        # Make a new record for the song.
        song.attributes = {title: info[:title],
                           album: album,
                           path: f,
                           length: info[:length],
                           track: info[:track]}
        if song.save
          # If we can save it, display a message
          puts "Song at path #{f} was saved. Woohoo!"
        else
          # Otherwise, just skip it. It might not have been a song in the
          # first place.
          puts "Song at path #{f} was not saved, skipping..."
        end
      end
    end

    def self.get_info(f)
      # Hash to store the info in
      i = {}
      # Open the file
      TagLib::FileRef.open(f) do |f|
        # We only do the next bit if hte fire actually opened.
        unless f.null?
          tag = f.tag
          prop = f.audio_properties
          ##
          # Set all the information.
          i[:artist] = tag.artist
          i[:track] = tag.track
          i[:album] = tag.album
          i[:title] = tag.title
          i[:length] = prop.length
        end
      end
      return i
    end
    ##
    # Return a string with all our info
    def self.pretty_print
      ## the string we will append info to:
      str = ""
      ##
      # For each artist...
      Artist.all.each do |a|
        ##
        # Add the artist to the string
        str << "#{a.title}\n"
        ##
        # Go through each of the artist's albums
        a.albums.each do |a|
          ##
          # Add the album title to the string, indented once
          str << "\t#{a.title}\n"
          ##
          # For each track on the album in order...
          a.songs.sort{|x, y| x.track <=> y.track }.each do |s|
            ## 
            # Add info about the song.
            #
            # First, get a nicely formatted loading time
            time_str = Time.at(s.length).utc.strftime("%H:%M:%S")
            ##
            # Then, add the title of the song, and the time it runs.
            # Indent twice.
            str << "\t\t #{s.title} (#{time_str})\n"
          end
          ##
          # Add a newline since we're on another album.
          str << "\n"
        end
        ##
        # Add two newlines since we're on a new artist
        str << "\n\s"
      end
      ##
      # Return the nicely formatted string.
      return str
    end
  end
end

