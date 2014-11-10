require 'thread'
module WavHead
  ##
  # This class provides a queue that sorts itself on every operation.
  # It is thread-safe.
  class ConstantlySortedQueue
    attr_accessor :array
    def initialize
      # Internally, queue is stored as an array
      @array = []
      # We have a mutex to protect this array for thread safety.
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
      @mut.synchronize{@array.unshift o}
    end
    ##
    # The item that will be returned by "pop" next.
    def next
      @mut.synchronize{@array.sort![-1]}
    end
    ##
    # Get the highestes element in the queue.
    # This also removes the item from the queue.
    def pop
      @mut.synchronize{@array.sort!.pop}
    end
    ##
    # Give the top(num) items in the queue.
    # So top(10) will give the top 10 items in the queue.
    def top(num)
      @mut.synchronize{@array.sort!.reverse.take(num)}
    end
    ##
    # See if an item is in our queue
    def include?(o)
      @mut.synchronize{@array.include?(o)}
    end
    ##
    # The size of the queue
    def size
      return @array.size
    end
  end
end
