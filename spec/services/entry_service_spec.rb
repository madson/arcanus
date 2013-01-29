require "spec_helper"

describe EntryService do
  let(:entry) { double }
  let(:decrypted_data) { "<protected data>" }
  let(:encrypted_data) { IO.binread("spec/fixtures/encrypted_data") }
  let(:password) { "123456" }
  let(:salt) { "A" * 128 }
  let(:iv) { "B" * 16 }

  subject { EntryService.new(entry) }

  before do
    Setting.stub(pbkdf_iterations: 1)
    entry.stub(password: password)
  end

  describe ".new" do
    it "receives an Entry object" do
      expect { EntryService.new(entry) }.to_not raise_error
    end
  end

  describe "#save" do
    it "returns false when entry is not valid" do
      entry.stub(valid?: false)
      expect(subject.save).to be_false
    end

    it "encrypts the content and then saves the entry" do
      OpenSSL::Random.stub(:random_bytes) do |bytes|
        case bytes
        when 128 then salt
        when 16 then iv
        end
      end

      entry.stub(valid?: true, content: decrypted_data)
      entry.should_receive(:encrypted_data=).with(encrypted_data)
      entry.should_receive(:save).and_return(true)

      expect(subject.save).to be_true
    end
  end

  describe "#decrypt" do
    before { entry.stub(encrypted_data: encrypted_data) }

    it "raises an exception when password is wrong" do
      expect {
        subject.decrypt("wrong password")
      }.to raise_error(EntryService::WrongPassword)
    end

    it "returns the decrypted data when password is right" do
      expect(subject.decrypt(password)).to be === decrypted_data
    end
  end
end