class AuthorService
  def initialize(author)
    @author = author
  end

  def save
    @author.valid? && hash_password && @author.save
  end

  def valid_password?(password)
    salt, hash = @author.hashed_password.unpack("a128 a*")
    hash === Digest.kdf(password, salt)
  end

  private

  def hash_password
    salt = OpenSSL::Random.random_bytes(128)
    hash = Digest.kdf(@author.password, salt)

    @author.hashed_password = [salt, hash].pack("a128 a*")
    true
  end
end