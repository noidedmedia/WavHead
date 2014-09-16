require 'rspec'
require_relative '../db'
require_relative '../wav_head_info.rb'
require_relative '../wav_head.rb'
RSpec.describe WavHead do
  let(:song1){ "song1" }
  let(:song2){ "song2" }
  it "Adds items to the queue" do
    head = WavHead.new
    expect{head.vote(song1)}.to change{head.count}.by(1)
  end
  it "sorts by votes" do
    head = WavHead.new
    2.times do 
      head.vote(song1)
    end
    3.times do
      head.vote(song2)
    end
    expect(head.next).to eq(song2)
  end
end
