require 'rspec'
require_relative '../lib/wav_head_constantly_sorted_queue'

RSpec.describe WavHead::ConstantlySortedQueue do
  it "keeps elements sorted" do
    c = WavHead::ConstantlySortedQueue.new
    c << 2 
    c << 1
    expect(c.next).to eq(2)
    c << 3
    c << 1
    expect(c.next).to eq(3)
  end
  it "gives back the top elements" do
    c = WavHead::ConstantlySortedQueue.new
    c << 2 
    c << 3
    c << 1
    expect(c.top(2)).to eq([3,2])
  end
  it "removes elements when popped" do
    c = WavHead::ConstantlySortedQueue.new
    c << 2
    c << 3
    c << 1
    expect(c.pop).to eq(3)
    expect(c.include? 3).to eq(false)
  end
  it "updates size properly" do
    c = WavHead::ConstantlySortedQueue.new
    c << 2 
    c << 2
    expect(c.size).to eq(2)
    expect{c << 10}.to change{c.size}.by(1)
  end
end
