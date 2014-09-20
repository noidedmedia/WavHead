require 'data_mapper'
require 'dm-sqlite-adapter'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/.db.sqlite")

class Song
  include DataMapper::Resource
  property :id, Serial
  property :track, Integer
  property :title, String, length: 300
  property :path, String, length: 600, required: true
  property :length, Integer, required: true
  belongs_to :album
  has 1, :artist, {through: :album}
  before :save do |song|
    song.title.gsub("/","%2F")
  end
end

class Album
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :art_path, String, length: 600
  belongs_to :artist, required: true
  has n, :songs

end

class Artist
  include DataMapper::Resource
  property :id, Serial
  property :title, String, required: true
  has n, :albums
  has n, :songs, through: :albums
end

DataMapper.finalize
DataMapper.auto_upgrade!
