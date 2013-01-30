class Author
  include Mongoid::Document

  attr_accessor :password

  attr_accessible :name, :password

  field :name
  field :hashed_password, type: Moped::BSON::Binary

  has_many :entries

  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 5 }, unless: :persisted?

  def hashed_password
    super.data
  end

  def hashed_password=(data)
    super Moped::BSON::Binary.new(:generic, data)
  end
end