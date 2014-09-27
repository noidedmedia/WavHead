require 'thread'
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
      @mut.synchronize{@array << o}
    end
    def next
      @mut.synchronize{@array.sort![-1]}
    end

    def pop
      @mut.synchronize{@array.sort!.pop}
    end
    def top(num)
      @mut.synchronize{@array.sort{|x,y| y <=> x}.take(num)}
      
    end
    def include?(o)
      @mut.synchronize{@array.include?(o)}
    end
    def size
      return @array.size
    end
  end
end
