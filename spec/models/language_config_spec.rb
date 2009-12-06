require 'spec_helper'

describe LanguageConfig do
  before(:each) do
    @valid_attributes = {
            :corpus_id => 1,
            :name => "Norwegian bokmål, written, Constraint Grammar",
            :tagger => :obt
    }
    @new_language_config = LanguageConfig.new
    @new_language_config.valid?
  end

  it "should create a new instance given valid attributes" do
    LanguageConfig.create!(@valid_attributes)
  end

  it "should belong to a corpus" do
    @new_language_config.errors.full_messages.should include("Corpus can't be blank")
  end

  it "should require a name" do
    @new_language_config.errors.full_messages.should include("Name can't be blank")
  end

  it "may use a tagger" do
    @new_language_config.should respond_to(:tagger)
  end
end