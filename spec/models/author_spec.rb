require "spec_helper"

describe Author do
  it { should respond_to :entries }
  it { should respond_to :entries= }
  it { should respond_to :password }
  it { should respond_to :password= }

  specify "a valid author will be saved" do
    expect(build(:author).save).to be_true
  end

  specify "an invalid author not will be saved" do
    expect(subject.save).to be_false
  end

  it "validates presence of name" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:name)
  end

  it "validates uniqueness of name" do
    author = create(:author, name: "maria")
    subject.name = author.name

    expect(subject).to_not be_valid
    expect(subject).to include_error("is already taken").on(:name)
  end

  it "validates presence of password" do
    expect(subject).to_not be_valid
    expect(subject).to include_error("can't be blank").on(:password)
  end

  it "validates length of password" do
    subject.password = "a" * 4

    expect(subject).to_not be_valid
    expect(subject).to include_error("is too short (minimum is 5 characters)").on(:password)
  end
end