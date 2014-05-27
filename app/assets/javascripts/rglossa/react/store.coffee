class Store
  constructor: (models, @plurals, @storeChangedHandler, autoLoad = false) ->
    @models = {}
    @models[model] = [] for model in models
    @fetchData(models) if autoLoad

  getPlural: (singular) -> @plurals[singular] ? "#{singular}s"

  fetchData: (models) ->
    promises = for model in models
      do (model) =>
        $.getJSON(model)
          .done( (res) =>
            @models[model] = res)
          .fail -> alert('Error fetching data from the server. Please reload the page.')
    $.when.apply(null, promises).done(=> @storeChangedHandler(@))


window.Store = Store