module Digest
  def self.hash(password)
    OpenSSL::Digest::SHA512.digest(password)
  end

  def self.kdf(password, salt)
    OpenSSL::PKCS5::pbkdf2_hmac(
      password,
      salt,
      Setting.pbkdf_iterations,
      512,
      "sha512"
    )
  end
end