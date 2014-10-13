require 'data_mapper'
require 'dm-sqlite-adapter'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/.db.sqlite")
##
# A quick function to change the name into a URL-safe form
# We keep this in here since it isn't used outside of this file
module WavHead
  def self.url_encode(u)
    return nil if u.nil?
    return u.gsub("/","-slash-")
      .gsub('"',"-quote-")
      .gsub("(","-paren-")
      .gsub(")","-paren-")
      .gsub("\\","-backslash-")
      .gsub("#","-numsign-")
      .gsub("'","-apost-")
  end
end
class Song
  include DataMapper::Resource
  property :id, Serial
  property :track, Integer
  property :title, String, length: 300
  property :path, String, length: 600, required: true
  property :safe_title, String, length: 600
  property :length, Integer, required: true
  belongs_to :album
  has 1, :artist, {through: :album}
  ##
  # Plays the song through the speakers
  def play!
    if /darwin/ =~ RUBY_PLATFORM
      command = "afplay"
    else
      command = "mplayer"
    end
    puts "Playing...."
    puts "#{command} #{self.path}"
    system command, path
  end
  before(:save) do
    self.safe_title = WavHead::url_encode(self.title)
  end
end

class Album
  include DataMapper::Resource
  property :id, Serial
  property :title, String, length: 300
  property :safe_title, String, length: 600
  property :art_path, String, length: 600
  belongs_to :artist, required: true
  has n, :songs
  def total_length
    Time.at self.songs.map(&:length).inject(&:+)
  end
  before(:save) do
    self.safe_title = WavHead::url_encode(title)
  end
end

class Artist
  include DataMapper::Resource
  property :id, Serial
  property :title, String, required: true, length: 300
  property :safe_title, String, length: 600
  has n, :albums
  has n, :songs, through: :albums
  before(:save) do
    self.safe_title = WavHead::url_encode(title.to_s)
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
