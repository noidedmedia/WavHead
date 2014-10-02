##
# This file contains a class to manage vote numbers.

module WavHead
  class VoteManager
    ##
    # Initialize with the amount of time a user should wait
    # Default of 3 hours.
    def initialize(time = 60*60*3)
      # Length of time to wait before a user can vote again
      @time = time
      # A hash of user => uservote
      @users = {}
    end
    ##
    # See if a user can vote on a song.
    def can_vote?(uuid, song)
      @users[uuid].can_vote? song
    end
    def vote!(uuid, song)
      @users[uuid] ||= UserVote.new(@time)
      @users[uuid].vote!(song)
    end
  end

  class UserVotes
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
      return true unless @songs[song]
      if Time.now > @songs[song]
        return true
      else
        return false
      end
    end
  end
end

