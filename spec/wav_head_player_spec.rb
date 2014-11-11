require 'rspec'
require_relative '../lib/wav_head_player.rb'
require_relative '../lib/db.rb'
RSpec.describe WavHead::Player do
  let(:song1){ "Song 1" }
  let(:song2){ "Song 2" }
  let(:song3){ "Song 3" }
  it "Adds items to the queue" do
    head = WavHead::Player.new
    expect{head.upvote(song1)}.to change{head.count}.by(1)#changes vote points by 2, changes queue size by 1
  end
  it "votes properly on items" do
    head = WavHead::Player.new
    3.times do
      head.upvote(song2)
    end
    expect(head.votes_for(song2)).to eq(6)
  end

  it "sorts by votes" do
    head = WavHead::Player.new
    2.times do 
      head.upvote(song1)
    end
    1.times do
      head.upvote(song2)
    end
    expect(head.next).to eq(song1)
    expect(head.top(3)).to eq([song1,song2])
  end
end
