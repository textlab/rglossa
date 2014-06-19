#= require ./corpus_info
#= require ../search_inputs/cwb_search_inputs

###* @jsx React.DOM ###

window.StartMain = React.createClass
  propTypes:
    store: React.PropTypes.object.isRequired
    statechart: React.PropTypes.object.isRequired
    corpus: React.PropTypes.object.isRequired
    query: React.PropTypes.string.isRequired
    handleQueryChanged: React.PropTypes.func.isRequired

  render: ->
    {store, statechart, corpus, query, handleQueryChanged} = @props
    {name, logo} = corpus

    # Select a component based on the search engine name, e.g. CwbSearchInputs
    searchEngine = corpus.search_engine or 'cwb'
    searchInputs = window["#{searchEngine[0].toUpperCase() + searchEngine.slice(1)}SearchInputs"]

    `<span>
      <CorpusInfo
        corpusName={name}
        corpusLogoUrl={logo} />
      <searchInputs
        store={store}
        statechart={statechart}
        corpus={corpus}
        query={query}
        handleQueryChanged={handleQueryChanged} />
    </span>`