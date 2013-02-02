require "spec_helper"

describe Cipher do
  let(:content) { "my protected data" }
  let(:key) { "my short key" }
  let(:salt) { "B" * 16 }
  let(:iv) { "C" * 16 }
  let(:hash) { "K" * 32 }

  let(:encrypted) {
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.iv = iv
    cipher.key = hash
    cipher.update(content) + cipher.final
  }

  describe ".encrypt" do
    it "encrypts content using AES 256 CBC" do
      Digest.should_receive(:kdf).with(key, salt, 32).and_return(hash)
      expect(Cipher.encrypt(key, salt, iv, content)).to be == encrypted
    end
  end

  describe ".decrypt" do
    it "decrypts content using AES 256 CBC" do
      Digest.should_receive(:kdf).with(key, salt, 32).and_return(hash)
      expect(Cipher.decrypt(key, salt, iv, encrypted)).to be == content
    end

    it "raises an error when key is wrong" do
      Digest.stub(hash: "a wrong hash for a wrong key bro")

      expect {
        Cipher.decrypt("wrong key", salt, iv, encrypted)
      }.to raise_error Cipher::WrongKey
    end
  end
end