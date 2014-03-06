App.CwbMultiwordTermComponent = Em.Component.extend
  classNames: ['table-cell']

  queryHasSingleTerm: Em.computed.equal('parentView.displayedQuery.length', 1)

  didInsertElement: ->
    tagsInput = @get('tagsInput')
    pos = @get('term.pos')

    tagsInput.addTag(pos) if pos
    tagsInput.addTag(term.value) for term in @get('term.features')

    @$('[data-add-term-button]').on('click', $.proxy(@addTerm, @))


  willDestroyElement: ->
    @$('[data-add-term-button]').off 'click'


  tagsInput: (->
    unless @_tagsInput
      @_tagsInput = @$('[data-term-tags]').tags(
        promptText: ' '
        afterDeletingTag: $.proxy(@_onTagRemoved, @)
      )
    @_tagsInput
  ).property()


  isLemma: ((key, value) ->
    if value?
      @set('term.isLemma', value)
      parentView = @get('parentView')
      parentView.displayedQueryDidChange()
      parentView.updateQuery()
    @get('term.isLemma')
  ).property('term.isLemma')

  isStart: ((key, value) ->
    if value?
      @set('term.isStart', value)
      parentView = @get('parentView')
      parentView.displayedQueryDidChange()
      parentView.updateQuery()
    @get('term.isStart')
  ).property('term.isStart')

  isEnd: ((key, value) ->
    if value?
      @set('term.isEnd', value)
      parentView = @get('parentView')
      parentView.displayedQueryDidChange()
      parentView.updateQuery()
    @get('term.isEnd')
  ).property('term.isEnd')

  didBecomeLast: (->
    if @get('term.isLast')
      Em.run.next => @$('[data-add-term-button]').on('click', $.proxy(@addTerm, @))
  ).observes('term.isLast')

  addTerm: (e) ->
    if e.screenX > 0 and e.screenY > 0
      @get('parentView').addTerm()

  removeTerm: ->
    @get('parentView').removeTerm(@get('term'))

  addPos: (pos) ->
    @set('term.pos', pos)
    @get('tagsInput').addTag(pos.value)
    @get('parentView').updateQuery()

  addFeature: (option, feature, pos) ->
    @get('term.features').pushObject
      attr: feature.attr
      value: option.value

    @get('tagsInput').addTag(option.value)

    # TODO: Figure out why observing the features array doesn't work so that we
    # have to do this manually
    parentView = @get('parentView')
    parentView.displayedQueryDidChange()
    parentView.updateQuery()


  # Called after a tag has been removed from the tag list. We need to remove
  # the tag from the term object as well.
  _onTagRemoved: (tag) ->
    parentView = @get('parentView')
    if tag is @get('term.pos.value')
      @set('term.pos', null)
    else
      features = @get('term.features')
      for feature in features
        if feature.value is tag
          features.removeObject(feature)
          #
          # TODO: Figure out why observing the features array doesn't work so that we
          # have to do this manually
          parentView.displayedQueryDidChange()

          break
    parentView.updateQuery()

  search: ->
    # Just forward to the controller of the parent view
    @get('parentView.controller').search()