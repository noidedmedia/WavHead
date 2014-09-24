require_relative '../lib/wav_head_player'
require_relative '../lib/db'

RSpec.describe WavHead::SongVote do
  it "initializes with a value of 1" do
    song = WavHead::SongVote.new(Song[0])
    expect(song.votes).to eq(1)
  end
  describe "voting" do
    it "doesn't let the user directly modify votes" do
      expect{WavHead::SongVote.new(Song[0]).votes = 10}.to raise_error
    end
    it "changes the vote count when voted on" do
      vote = WavHead::SongVote.new(Song[0])
      expect{vote.vote!}.to change{vote.votes}.by(1)
    end
  end
  describe "sorting" do
    let(:song1){WavHead::SongVote.new(Song[0])}
    let(:song2){WavHead::SongVote.new(Song[4])}
    let(:song3){WavHead::SongVote.new(Song[10])}
    it "sorts by votes" do
      3.times do
        song3.vote!
      end
      10.times do
        song2.vote!
      end
      ary = [song3, song1, song2]
      expect(ary.sort).to eq([song1, song3, song2])
    end
  end
end
