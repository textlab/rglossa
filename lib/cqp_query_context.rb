# This class contains all settings relevant to a CQP query and is
# necessary when constructing a SimpleCQP instance.

# Query spec
#
# A spec is hash that contains corpora symbols as keys and corpora
# sub specs as values. A sub spec is an array of word or interval
# specifications that generates a CQP query in the same sequence. Each
# specification is a hash with the :type key specifying if it's a :word
# or :interval specification.
#
# Word:
# 'type' => 'word
# 'string' => The word string
# 'attributes' => A hash with the attribute name as a string for the key
#   and the attribute value as the hash value in string form.
#
# Interval:
# 'type' => 'interval
# 'min' => Low end of the interval as an integer
# 'max' => High end of the interval as an integer
#
# Examples:
#
# { 'english' => [{'type' => 'word', 'string' => "lord", 'attributes' => { 'pos' => "NNP" }},
#                 {'type' => 'interval', 'min' => 0, 'max' => 3},
#                 {'type' => 'word', 'string' => "worlds"}]}
#
# Generates the following CQP query (with :case_insensitive
# and :corpus => "ENGLISH" set):
# [(word='lord'%c) & (pos='NNP')] []{0, 3} [(word='worlds'%c)]
#
# The following spec
# { 'english' => [{ 'type' => 'word', 'string' => 'the' }],
#   'arabic_u' => [{ 'type' => 'word', 'string' => 'fy' }],
#   'arabic_v' => [{ 'type' => 'word', 'string' => 'fiy' }]}
#
# Generates the following CQP query (with :corpus => "ENGLISH" set):
# "[(word='the')] :ARABIC_U [(word='fy')] :ARABIC_V [(word='fiy')]",

class CQPQueryContext
  attr_accessor :corpus, :context, :context_type, :alignment, :cutoff,
    :attributes, :structures, :registry, :id, :query_spec, :case_insensitive

  def initialize(opts={})
    # id indentifying query dumps, should only be populated with id's
    # generated by SimpleCQP (see SimpleCQP initializer).
    @id = opts[:id] || nil
    # see comments above
    @query_spec = opts[:query_spec] || nil
    # corpus identifier as a string as used by CQP
    @corpus = opts[:corpus] || nil
    
    @context = opts[:context] || [7, 7]
    @context_type = opts[:context_type] || :words

    # an array of corpus identifiers
    @alignment = opts[:alignment] || []

    @attributes = opts[:attributes] || :word
    @structures = opts[:structures] || nil

    # registry path as a string
    # must be set for all CQP operations
    @registry = opts[:registry] ||
      (CQPQueryContext.const_defined?('DEFAULT_REGISTRY') && DEFAULT_REGISTRY)
    Rails.logger.warn('WARNING: No registry specified!') unless @registry
    
    @case_insensitive = opts[:case_insensitive] || nil
    
    # if no alignments are specified and the context is for a query we set the
    # alignments automatically to the additional corpora set in the query
    if @alignment.count == 0 and @query_spec
      @alignment = alignment_from_query
    end
  end

  def left_context
    return @context[0]
  end

  def right_context
    return @context[1]
  end

  def context_type
    return @context_type.to_s
  end
  
  # extract additional aligned corpora from the query
  def alignment_from_query
    alignments = @query_spec.each_key.collect { |k| k.downcase }
    alignments.delete(@corpus.downcase)

    return alignments
  end
end
