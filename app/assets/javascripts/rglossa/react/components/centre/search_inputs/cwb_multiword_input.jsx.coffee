#= require ./cwb_multiword_term

###* @jsx React.DOM ###

window.CwbMultiwordInput = React.createClass
  propTypes:
    query: React.PropTypes.string.isRequired
    corpus: React.PropTypes.object.isRequired
    handleQueryChanged: React.PropTypes.func.isRequired

  getInitialState: ->
    queryTerms: @constructQueryTerms(@props.query)

  componentWillReceiveProps: (nextProps) ->
    @setState(queryTerms: @constructQueryTerms(nextProps.query))

  constructQueryTerms: (query) ->
    queryParts = @splitQuery(query)

    dq = []
    min = null
    max = null

    queryParts.forEach (item) =>
      if m = item.match(/\[\]\{(.+)\}/)
        [min, max] = @handleIntervalSpecification(m)
      else if m = item.match(/\[(.+)\]/)
        dq.push @handleAttributes(m, min, max)
        min = null
        max = null
      else
        word    = item.substring(1, item.length-1)
        isStart = /\.\+$/.test(word)
        isEnd   = /^\.\+/.test(word)
        word = word.replace(/^(?:\.\+)?(.+?)/, "$1").replace(/(.+?)(?:\.\+)?$/, "$1")

        dq.push
          word:     word
          features: []
          min:      min
          max:      max
          isStart:  isStart
          isEnd:    isEnd

        min = null
        max = null

    dq


  splitQuery: (query) ->
    query.match(/\[\]\{(.+)\}|"[^"\s]+"|\[[^\]]+\]/g) or ['']


  handleIntervalSpecification: (m) ->
    intervalText = m[1]
    min = max = null

    m2 = intervalText.match(/(\d+),/)
    min = m2[1] if m2

    m2 = intervalText.match(/,(\d+)/)
    max = m2[1] if m2

    [min, max]


  handleAttributes: (m, min, max) ->
    attributes = m[1].split(/\s*&\s*/)
    term =
      min: min
      max: max
      features: []

    for attr in attributes
      m2 = attr.match(/\(?(\S+)\s*=\s*"(\S+)"/)
      switch m2[1]
        when 'word', 'lemma'
          term.word = m2[2]
          term.isLemma = m2[1] is 'lemma'
          term.isStart = /\.\+$/.test(m2[2])
          term.isEnd = /^\.\+/.test(m2[2])
        when 'pos' then term[@.props.posAttr] = m2[2]
        else term.features.push(attr: m2[1], value: m2[2])

      # Remove any .+ at the beginning and/or end of the displayed form
      term.word = term.word.replace(/^(?:\.\+)?(.+?)/, "$1").replace(/(.+?)(?:\.\+)?$/, "$1")
    term


  handleTermChanged: (term, termIndex) ->
    queryTerms = @state.queryTerms
    queryTerms[termIndex] = term
    @props.handleQueryChanged(@constructCQPQuery(queryTerms))


  constructCQPQuery: (queryTerms) ->
    parts = for term in queryTerms
      {min, max, word, isLemma, isStart, isEnd, pos, features} = term
      attrs = []

      if isLemma or pos or features.length
        if word
          attr = if isLemma then 'lemma' else 'word'
          word = "#{word}.+" if isStart
          word = ".+#{word}" if isEnd
          word = "(#{attr}=\"#{word}\" %c)"
          attrs.push(word)

        if pos
          posAttr = @props.corpus.langs[0].tags?.attr
          pos = "#{posAttr}=\"#{pos.value}\""
          attrs.push(pos)

        for feature in features
          f = "#{feature.attr}=\"#{feature.value}\""
          attrs.push(f)

        str = '[' + attrs.join(' & ') + ']'
      else
        # Only the word attribute is specified, so use a simple string
        str = if word
          word = "#{word}.+" if isStart
          word = ".+#{word}" if isEnd
          "\"#{word}\""
        else ''
      if min or max
        str = "[]{#{min ? ''},#{max ? ''}} " + str

      str

    parts.join(' ')


  render: ->
    queryTerms = @state.queryTerms
    lastIndex = queryTerms.length - 1

    `<div className="row-fluid">
      <form className="form-inline multiword-search-form">
        <div style={{display: 'table'}}>
          <div style={{display: 'table-row'}}>
          {queryTerms.map(function(term, index) {
            return (
              <CwbMultiwordTerm
                term={term}
                termIndex={index}
                queryHasSingleTerm={this.props.query.length === 1}
                isFirst={index === 0}
                isLast={index === lastIndex}
                handleTermChanged={this.handleTermChanged} />
            )
          }, this)}
            <div style={{display: 'table-cell'}}>
              <button type="submit" className="btn btn-success" data-search="">Search</button>
            </div>
          </div>
        </div>
      </form>
    </div>`
