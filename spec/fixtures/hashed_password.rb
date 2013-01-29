#!/usr/bin/env ruby
require "openssl"

password = "123456"
salt     = "A" * 64

hash = OpenSSL::Digest::SHA512.digest(password)
hash = OpenSSL::PKCS5::pbkdf2_hmac(hash, salt, 1, 512, OpenSSL::Digest::SHA512.new)

pack = [salt, hash].pack("a64 a*")

IO.binwrite("#{File.dirname(__FILE__)}/hashed_password", pack)