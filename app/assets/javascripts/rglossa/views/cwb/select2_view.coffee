App.Select2View = Em.View.extend

  tagName: 'input type="hidden"'

  didInsertElement: ->
    @$().select2
      width: '100%'
      multiple: true
      placeholder: 'Click to select'
      ajax:
        url: "metadata_categories/#{@get('content.id')}/metadata_values"
        dataType: 'json'

        data: (term, page) -> {query: term, page: page}

        results: (data, page) =>
          {results: data.metadata_values}

