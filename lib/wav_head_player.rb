require 'singleton'
require 'pqueue'
require 'json'
module WavHead
  class Player
    attr_reader :current
    def initialize()
      @song_votes = {}
      if /darwin/ =~ RUBY_PLATFORM
        # Use afplay on the mac
        @command = "afplay"
      else
        # mplayer otherwise
        @command = "mplayer"
      end
      @queue = PQueue.new
    end
    def vote(song)
      if vote = @song_votes[song]
        # Incriment the vote count
        vote.vote!
      else
        @song_votes[song] = SongVote.new(song)
      end
      @queue << song unless @queue.include? song
      return true
    end
    def count
      @queue.size
    end
    def get
      @queue.pop
    end
    def next
      @queue.top if @queue
    end
    def start!
      Thread.new do
        play
      end
    end
    def play
      loop do
        if @queue && @queue.size > 0
          song = @queue.pop
          @current = CurrentSong.new(song)
          puts "Running a song!"
          puts "#{@command} #{song.path}"
          puts "#########################################"
          `#{@command} "#{song.path}"`
        end
      end
    end
    def top(num)
      @queue.to_a.take(num)
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
      hash[:artist] = @song.artist.name
      hash[:start_time] = @start_time
      hash[:end_time] = @end_time
      hash[:duration] = @song.length
      hash.to_json
    end

  end
  attr_reader :song
  attr_reader :start_time
  attr_reader :end_time
end
