require 'mutex'
module WavHead
  class ConstantlySortedQueue
    def initialize
      @array = []
      @mut = Mutex.new
    end
    ##
    # Alias of insert
    def <<(o)
      self.insert(o)
    end
    ##
    # Add a new element to the array
    def insert(o)
      @mut.lock
      @array << o
      @mut.unlock
      return true
    end
    def next
      @mut.lock
      to_ret = @array[-1]
      @mut.unlock
      return to_ret
    end

    def pop
      @mut.lock
      to_ret = @array.sort.pop
      @mut.unlock
    end
    def top(num)
      @mut.lock
      to_ret = @array.sort{|x,y| y <=> x}.take(num)
      @mut.unlock
      return to_ret
    end
    def include?(o)
      @mut.lock
      to_ret = @array.include?(o)
      @mut.unlock
      return to_ret
    end
    
  end
end
