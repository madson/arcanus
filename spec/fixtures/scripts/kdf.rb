#!/usr/bin/env ruby
require "openssl"

password = "123456"
salt     = "<salt>"
hash = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 1, 512, "SHA512")

IO.binwrite("spec/fixtures/bin/kdf", hash)