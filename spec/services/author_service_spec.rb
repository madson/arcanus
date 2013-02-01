require "spec_helper"

describe AuthorService do
  let(:author) { double }
  let(:salt) { "A" * 64 }
  let(:password) { "123456" }
  let(:hashed_password) { IO.binread("spec/fixtures/bin/hashed_password") }

  subject { AuthorService.new(author) }

  before do
    Setting.stub(pbkdf_iterations: 1)
    author.stub(password: password)
  end

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

    it "creates a new hashed password and then saves the author" do
      OpenSSL::Random.stub(random_bytes: salt)

      author.stub(valid?: true)
      author.should_receive(:hashed_password=).with(hashed_password)
      author.should_receive(:save).and_return(true)

      expect(subject.save).to be_true
    end
  end

  describe "#valid_password?" do
    before { author.stub(hashed_password: hashed_password) }

    it "returns true when given password is valid" do
      expect(subject.valid_password?(password)).to be_true
    end

    it "returns false when given password is wrong" do
      expect(subject.valid_password?("wrong password")).to be_false
    end
  end
end