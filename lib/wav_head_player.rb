require 'thread'
require 'pqueue'
require_relative 'wav_head_constantly_sorted_queue'
module WavHead
  class Player
    attr_reader :current
    def initialize()
      @song_votes = {}
      if /darwin/ =~ RUBY_PLATFORM
        # Use afplay on OS X
        @command = "afplay"
      else
        # mplayer otherwise
        @command = "mplayer"
      end
      @queue = WavHead::ConstantlySortedQueue.new
    end
    def votes_for(song)
      return 0 unless @song_votes[song]
      @song_votes[song].votes
    end
    def vote(song)
      if @song_votes[song]
        # Incriment the vote count
        @song_votes[song].vote!
      else
        @song_votes[song] = SongVote.new(song)
      end
      @queue << @song_votes[song]  unless @queue.include? @song_votes[song]

      return true
    end
    def count
      @queue.size
    end
    def next
      return @queue.next.song
    end
    def start!
      puts "######################"
      puts "#      WAV HEAD      #"
      puts "#      starting      #"
      puts "#        now         #"
      puts "######################"
      Thread.new do
        play
      end
    end
    def play
      loop do
        puts("Looping...")
        if @queue && @queue.size > 0
          song = @queue.next
          @current = CurrentSong.new(song)
          song.play!
        end
        unless @queue && @queue.size > 0
          # No more queue items.
          # Sleep a bit.
          puts "Nothing to play, sleeping for 5 seconds..."
          sleep(5)
        end
      end
    end
    def top(num)
      @queue.top(num).map{|i| i.song}
    end
  end

  ###################################################
  # This class is way too small to make a new file  #
  # for. So we just define it in here.              #
  ###################################################
  class SongVote
    # Start with one vote by default
    def initialize(song)
      self.song = song
      @votes = 1
    end
    attr_accessor :song
    attr_reader :votes
    def <=>(other)
      self.votes <=> other.votes
    end
    def vote!
      @votes = @votes + 1
    end
  end

  # Very simple container for info about the currently played song
  class CurrentSong
    def initialize(song)
      @song = song
      @start_time = Time.new
      @end_time = @start_time + @song.length
    end
    def to_json
      hash = {}
      hash[:title] = @song.title
      hash[:album] = @song.album.title
      hash[:artist] = @song.artist.title
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
