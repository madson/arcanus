require "spec_helper"

describe Digest do
  let(:hash_output) { IO.binread("spec/fixtures/hash_output") }
  let(:kdf_output) { IO.binread("spec/fixtures/kdf_output") }

  describe ".hash" do
    it "generates a sha512 hash using given password" do
      expect(Digest.hash("123456")).to be == hash_output
    end
  end

  describe ".kdf" do
    before { Setting.stub(pbkdf_iterations: 1) }

    it "generates a pbkdf2 hash using given password and salt" do
      expect(Digest.kdf("123456", "<salt>")).to be == kdf_output
    end
  end
end