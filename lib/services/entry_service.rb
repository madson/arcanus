class EntryService
  class WrongPassword < StandardError ; end

  def initialize(entry)
    @entry = entry
  end

  def save
    if @entry.valid?
      encrypt_content
      @entry.save
    else
      false
    end
  end

  def decrypt(password)
    salt, iv, encrypted = @entry.encrypted_data.unpack("a128 a16 a*")

    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = kdf(password, salt)
    decipher.iv = iv

    decipher.update(encrypted) + decipher.final
  rescue OpenSSL::Cipher::CipherError
    raise WrongPassword
  end

  private

  def encrypt_content
    salt = OpenSSL::Random.random_bytes(128)
    iv   = OpenSSL::Random.random_bytes(16)
    key  = kdf(@entry.password, salt)

    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.iv  = iv
    cipher.key = key

    encrypted = cipher.update(@entry.content) + cipher.final

    @entry.encrypted_data = [salt, iv, encrypted].pack("a128 a16 a*")
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