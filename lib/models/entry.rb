class Entry
  include Mongoid::Document

  attr_accessor :password
  attr_accessor :content

  attr_accessible :name, :content

  field :name
  field :encrypted_data, type: Moped::BSON::Binary

  belongs_to :author

  validates :author, associated: true, presence: true
  validates :name, presence: true
  validates :password, presence: true
  validates :content, presence: true

  def encrypted_data
    super.data
  end

  def encrypted_data=(data)
    super Moped::BSON::Binary.new(:generic, data)
  end
end