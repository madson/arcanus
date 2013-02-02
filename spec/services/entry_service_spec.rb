require "spec_helper"

describe EntryService do
  let(:entry) { double }
  let(:content) { "my protected content" }
  let(:password) { "my password" }
  let(:encrypted) { "<my encrypted content>" }
  let(:salt) { "A" * 32 }
  let(:iv) { "B" * 16 }

  subject { EntryService.new(entry) }
  before { Setting.stub(pbkdf_iterations: 1) }

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
      OpenSSL::Random.stub(:random_bytes).and_return(salt, iv)
      entry.stub(valid?: true, content: content, password: password)

      Cipher.should_receive(:encrypt).with(password, salt, iv, content).and_return(encrypted)

      entry.should_receive(:encrypted_data=).with("#{salt}#{iv}#{encrypted}")
      entry.should_receive(:save).and_return(true)

      expect(subject.save).to be_true
    end
  end

  describe "#decrypt" do
    it "returns the decrypted content" do
      entry.stub(encrypted_data: "#{salt}#{iv}#{encrypted}")
      Cipher.should_receive(:decrypt).with(password, salt, iv, encrypted).and_return(content)

      expect(subject.decrypt(password)).to be == content
    end
  end
end