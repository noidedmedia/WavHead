##
# This file contains a class to manage vote numbers.

module WavHead
  class VoteManager
    ##
    # Initialize with the amount of time a user should wait
    # Default of 3 hours.
    attr_accessor :downvote
    
    def initialize(config_settings)
      # Length of time to wait before a user can vote again
      #read from YAML config file
      @downvote = config_settings["enable_downvotes"]=="true"

      @time = config_settings["time_between_votes"]
      @time = 60*60*3 unless @time.is_a? Integer

      @queue_threshold = config_settings["voted_out_of_queue_limit"].to_i
      @queue_threshold = 0 if @queue_threshold > 0
      # Doesn't matter what threshold is if songs can't be downvoted

      # A hash of user => uservote
      @users = {}
    end
    ##
    # See if a user can vote on a song.
    def can_vote?(uuid, song)
      puts "Seeing if user with id #{uuid} can vote on #{song.inspect}"
      return true unless @users[uuid]
      @users[uuid].can_vote? song
    end
    def vote!(uuid, song)
      @users[uuid] = WavHead::UserVote.new(@time) unless @users[uuid]
      @users[uuid].vote!(song)
    end

  end

  class UserVote
    ## 
    # Time is the amount of time to wait before a user can vote on a song again
    def initialize(time)
      @time = time
      # Hash of Song -> Time we can vote again
      @songs = {}
    end
    ##
    # A user has voted on a song
    # Prevent them from voting again for @time amount of time.
    def vote!(song)
      @songs[song] = Time.now + @time
    end
    def can_vote?(song)
      puts "Checking to see if a user can vote..."
      return true unless @songs[song]
      if Time.now > @songs[song]
        puts "We can play it."
        return true
      else
        puts "Nope, unplayable! We can play again at #{@songs[song]}"
        return false
      end
    end
  end
end

