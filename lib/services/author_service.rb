class AuthorService
  def initialize(author)
    @author = author
  end

  def save
    @author.valid? && hash_password && @author.save
  end

  def valid_password?(password)
    salt, hash = @author.hashed_password.unpack("a64 a*")
    hash === Digest.kdf(Digest.hash(password), salt)
  end

  private

  def hash_password
    salt = OpenSSL::Random.random_bytes(64)
    hash = Digest.kdf(Digest.hash(@author.password), salt)

    @author.hashed_password = [salt, hash].pack("a64 a*")
    true
  end
end