module Rglossa
  class CorpusText < ActiveRecord::Base
    has_and_belongs_to_many :metadata_values

    class << self
    # Returns all corpus texts that are associated with the metadata values
    # that have the given database ids
    def matching_metadata(metadata_value_ids)
      CorpusText
      .select('corpus_texts.startpos, corpus_texts.endpos').uniq
      .joins('INNER JOIN corpus_texts_metadata_values ON ' +
        'corpus_texts_metadata_values.corpus_text_id = corpus_texts.id')
      .where(
        corpus_texts_metadata_values: { metadata_value_id: metadata_value_ids }
        )
    end
  end
end