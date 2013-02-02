require "spec_helper"

describe Digest do
  let(:sha512_hash) { OpenSSL::Digest::SHA512.digest("123456") }
  let(:pbkdf2_hash) { OpenSSL::PKCS5.pbkdf2_hmac("123456", "my salt", 1, 512, "SHA512") }
  let(:pbkdf2_hash_32) { OpenSSL::PKCS5.pbkdf2_hmac("123456", "my salt", 1, 32, "SHA512") }

  describe ".hash" do
    it "generates a SHA512 digest of the given string" do
      expect(Digest.hash("123456")).to be == sha512_hash
    end
  end

  describe ".kdf" do
    before { Setting.stub(pbkdf_iterations: 1) }

    it "generates a PBKDF2 hash of the given string" do
      expect(Digest.kdf("123456", "my salt")).to be == pbkdf2_hash
    end

    it "generates a PBKDF2 hash using the given length" do
      expect(Digest.kdf("123456", "my salt", 32)).to be == pbkdf2_hash_32
    end
  end
end