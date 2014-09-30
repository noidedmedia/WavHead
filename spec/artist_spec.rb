require 'rspec'
require_relative '../lib/db'
require_relative '../lib/wav_head_info'
RSpec.describe Artist do
  
  it "saves a URL-safe title" do
    title = "asdf\\ () \" ///"
    a = Artist.new(title: title)
    expect(a.save).to eq(true)
    expect(a.safe_title).to eq(WavHead::url_encode(title))
  end

end
