#!/usr/bin/env ruby
require "openssl"

password = "123456"
salt     = "A" * 128
iv       = "B" * 16
data     = "<protected data>"

key = OpenSSL::PKCS5::pbkdf2_hmac(password, salt, 1, 512, OpenSSL::Digest::SHA512.new)

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
cipher.iv  = iv
cipher.key = key

encrypted = cipher.update(data) + cipher.final
pack = [salt, iv, encrypted].pack("a128 a16 a*")

IO.binwrite("#{File.dirname(__FILE__)}/encrypted_data", pack)