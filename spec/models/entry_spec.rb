require "spec_helper"

describe Entry do
  it { should respond_to :author }
  it { should respond_to :author= }
  it { should respond_to :password }
  it { should respond_to :password= }
  it { should respond_to :content }
  it { should respond_to :content= }

  specify "a valid entry will be saved" do
    expect(build(:entry).save).to be_true
  end

  specify "an invalid entry not will be saved" do
    expect(subject.save).to be_false
  end

  it "validates presence of author" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:author)
  end

  it "validates associated author" do
    subject.author = Author.new

    expect(subject).to_not be_valid
    expect(subject).to include_error("is invalid").on(:author)
  end

  it "validates presence of name" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:name)
  end

  it "validates presence of content" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:content)
  end

  it "validates presence of password" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:password)
  end
end