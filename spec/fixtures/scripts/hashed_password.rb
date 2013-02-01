#!/usr/bin/env ruby
require "openssl"

password = "123456"
salt     = "A" * 64

hash = OpenSSL::Digest::SHA512.digest(password)
hash = OpenSSL::PKCS5::pbkdf2_hmac(hash, salt, 1, 512, "SHA512")

pack = [salt, hash].pack("a64 a*")

IO.binwrite("spec/fixtures/bin/hashed_password", pack)