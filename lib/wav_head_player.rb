require 'thread'
require 'pqueue'
require_relative 'wav_head_constantly_sorted_queue'
##
# Semi-literate programming, begin!
# WavHead::Player provides a very simple method of playing songs
# by order of votes.
module WavHead
  class Player
    ##
    # current is the song currently being played.
    attr_reader :current
    def initialize()
      ##
      # This is a hash of Song (or Song-like) to SongVote.
      # This allows us to update the number of votes on a song without
      # having to pass SongVote objects around everywhere.
      @song_votes = {}
      ##
      # @queue is the current queue. It is a WavHead::ConstantlySortedQueue, 
      # which is essentially a queue that re-orders itself on each operation.
      @queue = WavHead::ConstantlySortedQueue.new
    end
    def votes_for(song)
      ##
      # If the song is not in the hash, it has no votes for it yet.
      # So we return 0.
      return 0 unless @song_votes[song]
      # Otherwise, return the votes on the song.
      @song_votes[song].votes
    end
    ##
    # This method takes a Song (or Song-like) and votes for it
    def vote(song)
      if @song_votes[song]
        # If the song is in the hash, it has votes for it already.
        # We call "vote!" on the SongVote object in order to increase the
        # vote count.
        @song_votes[song].vote!
      else
        # The song has not yet been voted on. We create a new SongVote for the
        # song, and add it to the hash.
        @song_votes[song] = SongVote.new(song)
      end
      ##
      # Add the song to the queue unless it's already there. 
      # It should only be there if it has a SongVote in the hash already.
      @queue << @song_votes[song]  unless @queue.include? @song_votes[song]
      return true
    end
    ##
    # How many songs are in the queue
    def count
      @queue.size
    end
    ##
    # How many songs are in the queue
    def size
      @queue.size
    end
    ##
    # The song we will be playing next.
    def next
      return @queue.next.song
    end
    ##
    # Start playing the song in a queue
    def start!
      ##
      # Display a nice message
      puts "######################"
      puts "#      WAV HEAD      #"
      puts "#      starting      #"
      puts "#        now         #"
      puts "######################"
      Thread.abort_on_exception = true # Crash the server if something goes 
      # horribly wrong in a thread
      Thread.new do
        ##
        # In a new Thread, we run the "play" loop.
        play
      end
    end
    def play
      ##
      # Go through the queue, playing songs
      loop do
        puts("Looping...")
        ##
        # If we have a song...
        if @queue && @queue.size > 0
          song = @queue.pop.song
          puts "Sending play to #{song.inspect}"
          ##
          # Set current to a new CurrentSong.
          # A "CurrentSong" is an object with the currently played song,
          # and some info about how it is being played.
          @current = CurrentSong.new(song)
          ##
          # Play the song.
          song.play!
          ##
          # Set nothing to be currently playing
          @current = nil
          ##
          # Remove it from the queue, so people can vote on it again.
          @song_votes[song] = nil
        end
        unless @queue && @queue.size > 0
          ##
          # Unless we have new songs to play, we sleep for a bit.
          # This makes the server a bit faster.
          puts "Nothing to play, sleeping for 5 seconds..."
          sleep(5)
        end
      end
    end
    ##
    # Returns an array of the top num songs in the queue.
    # So if you call top(10), the top 10 songs will be returned, in order.
    def top(num)
      @queue.top(num).map{|i| i.song}
    end
  end
  ##
  # The SongVote class is a simple way of connecting songs to votes.
  class SongVote
    # Associate a song to a vote count, and start the count off at 1.
    def initialize(song)
      self.song = song
      @votes = 1
    end
    ## 
    # Allow the song and the votes to be read but not modified
    attr_accessor :song
    attr_reader :votes
    ##
    # Properly set up the comparison to sort in order of votes.
    def <=>(other)
      self.votes <=> other.votes
    end
    ## 
    # incriment the vote count by 1.
    def vote!
      @votes = @votes + 1
    end
  end

  # Very simple container for info about the currently played song
  # This assumes that the song starts playing on initialization.
  class CurrentSong
    def initialize(song)
      @song = song
      @start_time = Time.new
      @end_time = @start_time + @song.length
    end
    def to_json
      hash = {}
      hash[:title] = @song.title
      hash[:safe_title] = @song.safe_title
      hash[:album] = @song.album.title
      hash[:safe_album] = @song.album.safe_title
      hash[:artist] = @song.artist.title
      hash[:safe_artist] = @song.artist.safe_title
      hash[:start_time] = @start_time
      hash[:end_time] = @end_time
      hash[:duration] = @song.length
      hash[:timeleft] = @end_time - Time.new
      hash[:percentfinished] =  (hash[:duration] - hash[:timeleft]) / hash[:duration]
      hash.to_json
    end
    attr_reader :song
    attr_reader :start_time
    attr_reader :end_time
  end
end
