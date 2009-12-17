class Subcorpus < ActiveRecord::Base
  belongs_to :corpus
  validates_presence_of :corpus_id
  
  has_and_belongs_to_many :corpus_texts
end
