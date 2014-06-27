#= require rglossa/react/utils
#= require ./main_area_top
#= require ./main_area_bottom

###* @jsx React.DOM ###

window.MainArea = React.createClass
  propTypes:
    store: React.PropTypes.object.isRequired
    statechart: React.PropTypes.object.isRequired
    corpus: React.PropTypes.object.isRequired

  getInitialState: ->
    searchQuery: ''
    maxHits: 2000
    lastSelectedMaxHits: null

  handleQueryChanged: (query) ->
    # When the query changes, also set maxHits to the last requested number of
    # hits if we have asked to see all hits in the mean time, in which case
    # @state.maxHits will be null. This way, we will always limit the number of
    # hits each time we do a new query.
    newState = searchQuery: query
    if !@state.maxHits and @state.lastSelectedMaxHits
      newState.maxHits = @state.lastSelectedMaxHits
    @setState(newState)

  handleMaxHitsChanged: (maxHits) ->
    newState = maxHits: maxHits
    if maxHits is null and @state.maxHits
      # if we ask for all hits, remember what number of hits we asked for
      # last time so that we can use the same number when doing the next search
      newState.lastSelectedMaxHits = @state.maxHits

    @setState(newState)
    @handleSearch(newState)

  showCorpusHome: ->
    alert 'showCorpusHome'

  handleSearch: (newState = {}) ->
    state = rglossaUtils.merge(@state, newState)
    {store, statechart, corpus} = @props

    # Remove any previous search results so that a spinner will be
    # shown until the new results are received from the server
    statechart.changeValue('searchId', null, true)

    searchEngine = corpus.search_engine ?= 'cwb'
    searchUrl = "search_engines/#{searchEngine}_searches"
    query =
      query: state.searchQuery
      corpusShortName: corpus.short_name

    $.ajax(
      url: searchUrl
      method: 'POST'
      data: JSON.stringify
        queries: [query]
        max_hits: state.maxHits
      dataType: 'json'
      contentType: 'application/json'
    ).then (res) =>
      searchModel = "#{searchEngine}_search"
      search = res[searchModel]
      id = search.id

      if !@state.maxHits or search.num_hits < @state.maxHits
        # There were fewer than maxHits occurrences in the corpus
        search.total = search.num_hits
      else
        # There were at least maxHits occurrences in the corpus; find out the total
        $.getJSON("#{searchUrl}/#{id}/count").then (count) =>
          # Update the search model in the store with the total
          model = store.find('search', id)
          model.total = count
          store.setData('search', id, model)

      search.pages = search.first_two_result_pages

      delete search.pages['2'] if search.pages['2'].length is 0
      delete search.first_two_result_pages

      store.setData('search', id, search)
      statechart.handleAction('showResults', id)

    statechart.handleAction('showResults', null)


  render: ->
    {store, statechart, corpus} = @props
    searchId = statechart.getValue('searchId')
    results = if searchId then store.find('search', searchId) else null

    `<span>
      <div className="container-fluid">

        <MainAreaTop
          statechart={statechart}
          corpus={corpus}
          results={results}
          maxHits={this.state.maxHits}
          handleMaxHitsChanged={this.handleMaxHitsChanged} />

        <MainAreaBottom
          store={store}
          statechart={statechart}
          corpus={corpus}
          results={results}
          searchQuery={this.state.searchQuery}
          handleQueryChanged={this.handleQueryChanged}
          maxHits={this.state.maxHits}
          handleSearch={this.handleSearch} />
      </div>
    </span>`
