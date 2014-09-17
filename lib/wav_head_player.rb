require 'singleton'
require 'pqueue'
module WavHead
  class Player
    def initialize()
      @song_votes = {}
      @queue = PQueue.new do |x, y|
        @song_votes[x] <=> @song_votes[y]
      end
      if /darwin/ =~ RUBY_PLATFORM
        # Use afplay on the mac
        @command = "afplay"
      else
        # mplayer otherwise
        @command = "mplayer"
      end 
    end
    def vote(song)
      if num_votes = @song_votes[song]
        @song_votes[song] = num_votes + 1
      else
        @song_votes[song] = 1
      end
      @queue << song unless @queue.include? song
      @queue = PQueue.new(@queue){|x,y| @song_votes[x] <=> @song_votes[y]}
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
    def start
      Thread.new do
        play
      end
    end
    def play
      loop do
        if @queue && @queue.size > 0
          `#{@command} "#{@queue.pop.path}"`
        end
      end
    end
  end
end
