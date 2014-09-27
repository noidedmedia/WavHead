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
  it "updates size properly" do
    c = WavHead::ConstantlySortedQueue.new
    c << 2 
    c << 2
    expect(c.size).to eq(2)
    expect{c << 10}.to change{c.size}.by(1)
  end
end
