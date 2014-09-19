require 'singleton'
require 'pqueue'
module WavHead
  class Player
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
          @current = @queue.pop
          puts 80.times.map{|x| "#"}.join("")
          puts "Playing song #{@current.title}"
          puts "(#{@current.path})"
          puts "(#{@command} \"#{@current.path}\""
          puts 80.times.map{|x| "#"}.join("")

          `#{@command} "#{@current.path}"`
        end
      end
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
    def vote!
      @votes = @votes + 1
    end
    def <=>(other)
      self.votes <=> other.votes
    end
  end
end
