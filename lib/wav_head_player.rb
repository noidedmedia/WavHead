require 'thread'
require 'pqueue'
require 'json'
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
      @queue_mut = Mutex.new
      @queue = Array.new
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
      @queue_mut.lock
      @queue << @song_votes[song]  unless @queue.include? @song_votes[song]
      @queue.sort!
      @queue_mut.unlock
      return true
    end
    def count
      @queue.size
    end
    def get
      @queue.pop.song
    end
    def next
      @queue_mut.lock
      @queue.sort!
      @queue_mut.unlock
      return @queue[-1].song
    end
    def start!
      Thread.new do
        play
      end
    end
    def play
      loop do
        if @queue && @queue.size > 0
          @queue_mut.lock
          @queue.sort!
          song = @queue.pop
          @current = CurrentSong.new(song)
          @queue_mut.unlock
          puts "Running a song!"
          puts "#{@command} #{song.path}"
          puts "#########################################"
          `#{@command} "#{song.path}"`
        end
      end
    end
    def top(num)
      @queue_mut.lock
      @top = @queue.sort{|x, y| y <=> x}
      @queue_mut.unlock
      return @top.map{|t| t.song}.take(num)
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
    ##
    # Okay, so this next bit is technically bad design.
    # Sorting is, by default, ascending. However, we want it to be
    # sorted in descending order so the queue works properly. So
    # we just use this hack, so we don't have to tell the queue
    # to use the right block every time we add items
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
