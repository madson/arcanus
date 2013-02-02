module Cipher
  class WrongKey < StandardError ; end

  def self.encrypt(key, salt, iv, content)
    cipher = new_cipher
    cipher.encrypt
    cipher.iv  = iv
    cipher.key = Digest.kdf(key, salt, 32)

    cipher.update(content) + cipher.final
  end

  def self.decrypt(key, salt, iv, content)
    cipher = new_cipher
    cipher.decrypt
    cipher.key = Digest.kdf(key, salt, 32)
    cipher.iv = iv

    cipher.update(content) + cipher.final
  rescue OpenSSL::Cipher::CipherError
    raise WrongKey
  end

  private

  def self.new_cipher
    OpenSSL::Cipher::AES.new(256, :CBC)
  end
end