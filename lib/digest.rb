module Digest
  def self.hash(password)
    OpenSSL::Digest::SHA512.digest(password)
  end

  def self.kdf(password, salt, len = 512)
    OpenSSL::PKCS5::pbkdf2_hmac(password, salt, Setting.pbkdf_iterations, len, "SHA512")
  end
end