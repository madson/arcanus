require "spec_helper"

describe AuthorService do
  let(:author) { double }
  let(:password) { "123456" }
  let(:salt) { "A" * 64 }
  let(:hash) { "<hashed password>" }
  let(:kdf) { "<kdf password>" }
  let(:hashed_password) { salt + kdf }

  before { author.stub(password: password, hashed_password: hashed_password) }
  subject { AuthorService.new(author) }

  describe ".new" do
    it "receives an Author object" do
      expect { AuthorService.new(author) }.to_not raise_error
    end
  end

  describe "#save" do
    it "returns false when author is not valid" do
      author.stub(valid?: false)
      expect(subject.save).to be_false
    end

    it "hashes password and then saves author" do
      OpenSSL::Random.stub(random_bytes: salt)

      Digest.should_receive(:hash).with(password).and_return(hash)
      Digest.should_receive(:kdf).with(hash, salt).and_return(kdf)

      author.stub(valid?: true)
      author.should_receive(:hashed_password=).with(salt + kdf)
      author.should_receive(:save).and_return(true)

      expect(subject.save).to be_true
    end
  end

  describe "#valid_password?" do
    it "returns true when given password is valid" do
      Digest.should_receive(:hash).with(password).and_return(hash)
      Digest.should_receive(:kdf).with(hash, salt).and_return(kdf)

      expect(subject.valid_password?(password)).to be_true
    end

    it "returns false when given password is wrong" do
      password = "wrong password"

      Digest.should_receive(:hash).with(password).and_return(hash)
      Digest.should_receive(:kdf).with(hash, salt).and_return("<wrong kdf>")

      expect(subject.valid_password?(password)).to be_false
    end
  end
end