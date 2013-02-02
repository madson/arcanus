class EntryService
  def initialize(entry)
    @entry = entry
  end

  def save
    @entry.valid? && encrypt_content && @entry.save
  end

  def decrypt(password)
    salt, iv, encrypted = @entry.encrypted_data.unpack("a32 a16 a*")
    Cipher.decrypt(password, salt, iv, encrypted)
  end

  private

  def encrypt_content
    salt = OpenSSL::Random.random_bytes(32)
    iv   = OpenSSL::Random.random_bytes(16)
    content = @entry.content
    password = @entry.password

    encrypted = Cipher.encrypt(password, salt, iv, content)

    @entry.encrypted_data = [salt, iv, encrypted].pack("a32 a16 a*")
    true
  end
end