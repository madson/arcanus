class AuthorService
  def initialize(author)
    @author = author
  end

  def save
    if @author.valid?
      hash_password
      @author.save
    else
      false
    end
  end

  def valid_password?(password)
    salt, hash = @author.hashed_password.unpack("a64 a*")
    hash === kdf(hash(password), salt)
  end

  private

  def hash_password
    salt = OpenSSL::Random.random_bytes(64)
    hash = kdf(hash(@author.password), salt)

    @author.hashed_password = [salt, hash].pack("a64 a*")
  end

  def hash(password)
    OpenSSL::Digest::SHA512.digest(password)
  end

  def kdf(password, salt)
    OpenSSL::PKCS5::pbkdf2_hmac(
      password,
      salt,
      Setting.pbkdf_iterations,
      512,
      OpenSSL::Digest::SHA512.new
    )
  end
end