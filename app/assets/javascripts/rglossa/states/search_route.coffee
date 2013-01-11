App.SearchRoute = Em.Route.extend

  model: (params) ->
    corpus = @controllerFor('corpus').setCorpus(params['corpus_short_name'])

  setupController: (controller, model) ->
    @controllerFor('metadataAccordion').set('corpusController', @controllerFor('corpus'))

  renderTemplate: ->
    # Metadata selection is independent of the type of search interface, so
    # render the metadata accordion in the sidebar for all search interfaces.
    # The rest of the search interface will be rendered by a substate that is
    # determined by the desired search type (CWB, Corpuscle etc.)
    @render 'metadataAccordion',
      outlet: 'leftSidebar',
      controller: 'metadataAccordion'

  #########################
  # Non-routable substates
  #########################

  # When we go from one page of search results to the next, we need to
  # traverse out of the search.results state and re-enter it in order to set
  # the new page number in the URL. Hence we got to this non-routable state,
  # which simply redirects back to the search.results state with new
  # parameters.
  changingResultPage: Em.State.create

    redirect: ->
      params =
        cwb_search_id: router.get('searchController.id')
        page_no: router.get('resultToolbarController.currentPageNo') + 1

      @transitionTo('search.results', params)
