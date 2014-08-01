#= require ../../../statechart
#= require rglossa/models/corpus
#= require ./language_select
#= require ./cwb_simple_input
#= require ./cwb_multiword_input
#= require ./cwb_regex_input

###* @jsx React.DOM ###

# Search inputs for corpora encoded with the IMS Corpus Workbench

root =
  initialSubstate: 'simple'
  substates:
    simple: {}
    multiword: {}
    regex: {}
  actions:
    showSimple: -> @transitionTo('simple')
    showMultiword: -> @transitionTo('multiword')
    showRegex: -> @transitionTo('regex')

window.CwbSearchInputs = React.createClass
  propTypes:
    store: React.PropTypes.object.isRequired
    statechart: React.PropTypes.object.isRequired
    corpus: React.PropTypes.object.isRequired
    searchQueries: React.PropTypes.array.isRequired
    handleQueryChanged: React.PropTypes.func.isRequired
    handleSearch: React.PropTypes.func.isRequired
    handleAddLanguage: React.PropTypes.func.isRequired
    handleAddPhrase: React.PropTypes.func.isRequired

  getInitialState: ->
    statechart: new Statechart(
      'CwbSearchInputs', root, (sc) => @setState(statechart: sc))

  showSimple: (e) ->
    e.preventDefault()
    @state.statechart.handleAction('showSimple')

  showMultiword: (e) ->
    e.preventDefault()
    @state.statechart.handleAction('showMultiword')

  showRegex: (e) ->
    e.preventDefault()
    @state.statechart.handleAction('showRegex')

  languageSelect: (query) ->
    `<LanguageSelect
      corpus={this.props.corpus}
      selectedValue={query.lang} />`

  languageAddButton: ->
    `<button className="btn" style={{marginLeft: 20}} onClick={this.props.handleAddLanguage}>Add language</button>`

  searchButton: (isMultilingual) ->
    marginLeft = if isMultilingual then 80 else 40  # adjust position relative to the language select
    `<button type="button" className="btn btn-success"
        style={{marginLeft: marginLeft}} onClick={this.props.handleSearch}>Search</button>`

  addPhraseButton: ->
    `<button className="btn add-phrase-btn" onClick={this.props.handleAddPhrase}>Or...</button>`


  render: ->
    {corpus, searchQueries, handleQueryChanged, handleSearch} = @props
    isMultilingual = corpusNs.isMultilingual(@props.corpus)

    if @state.statechart.pathContains('simple')
      `<span>
        <div className="row-fluid search-input-links">
          <b>Simple</b>&nbsp;|&nbsp;
          <a href="" title="Search for grammatical categories etc." onClick={this.showMultiword}>Extended</a>&nbsp;|&nbsp;
          <a href="" title="Regular expressions" onClick={this.showRegex}>Regexp</a>
          {this.searchButton(isMultilingual)}
          {isMultilingual ? this.languageAddButton() : null}
        </div>
        {searchQueries.map(function(searchQuery, index) {
          return ([
            isMultilingual ? this.languageSelect(searchQuery) : null,
            <CwbSimpleInput
              searchQuery={searchQuery}
              handleQueryChanged={handleQueryChanged.bind(null, index)}
              handleSearch={handleSearch} />
          ])
        }.bind(this))}
        {isMultilingual ? null : this.addPhraseButton()}
      </span>`

    else if @state.statechart.pathContains('multiword')
      `<span>
        <div className="row-fluid search-input-links">
          <a href="" title="Simple search box" onClick={this.showSimple}>Simple</a>&nbsp;|&nbsp;
          <b>Extended</b>&nbsp;|&nbsp;
          <a href="" title="Regular expressions" onClick={this.showRegex}>Regexp</a>
          {this.searchButton(isMultilingual)}
          {isMultilingual ? this.languageAddButton() : null}
        </div>
        {searchQueries.map(function(searchQuery, index) {
          return ([
            isMultilingual ? this.languageSelect(searchQuery) : null,
            <CwbMultiwordInput
              searchQuery={searchQuery}
              corpus={corpus}
              handleQueryChanged={handleQueryChanged.bind(null, index)}
              handleSearch={handleSearch} />
          ])
        }.bind(this))}
        {isMultilingual ? null : this.addPhraseButton()}
      </span>`

    else
      `<span>
        <div className="row-fluid search-input-links">
          <a href="" title="Simple search box" onClick={this.showSimple}>Simple</a>&nbsp;|&nbsp;
          <a href="" title="Search for grammatical categories etc." onClick={this.showMultiword}>Extended</a>&nbsp;|&nbsp;
          <b>Regexp</b>
          {this.searchButton(isMultilingual)}
          {isMultilingual ? this.languageAddButton() : null}
        </div>
        {searchQueries.map(function(searchQuery, index) {
          return ([
            isMultilingual ? this.languageSelect(searchQuery) : null,
            <CwbRegexInput
              searchQuery={searchQuery}
              handleQueryChanged={handleQueryChanged.bind(null, index)}
              handleSearch={handleSearch} />
          ])
        }.bind(this))}
        {isMultilingual ? null : this.addPhraseButton()}
      </span>`