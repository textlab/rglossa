require 'spec_helper'

describe CorpusText do
  before(:each) do
    @valid_attributes = {
      :corpus_id => 1
    }
    @new_corpus_text = CorpusText.new
    @new_corpus_text.valid?
  end

  it "should create a new instance given valid attributes" do
    CorpusText.create!(@valid_attributes)
  end

  it "should belong to a corpus" do
    @new_corpus_text.errors.full_messages.should include("Corpus can't be blank")
  end

  it "should have and belong to many subcorpora" do
    @new_corpus_text.should respond_to(:subcorpora)
  end
end