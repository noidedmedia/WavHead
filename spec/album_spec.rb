require 'rspec'
require_relative '../lib/db'
require_relative '../lib/wav_head_info.rb'
RSpec.describe Album do

  let(:artist){Artist.new(title: "test")}
  it "requires an album" do
    a = Album.new
    a.title = "asdf"
    expect(a.save).to eq(false)
    a.artist = artist
    expect(a.save).to eq(true)
  end
  it "saves a URL-safe title" do
    title = "asdfadf \\ \" () "
    a = Album.new
    a.artist = artist
    a.title = title
    expect(a.save).to eq(true)
    expect(a.safe_title).to eq(WavHead::url_encode(title))
  end
end
