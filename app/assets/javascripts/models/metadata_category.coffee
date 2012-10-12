App.MetadataCategory = DS.Model.extend
  localizedName: DS.attr('string')

  values: DS.hasMany('App.MetadataValue', embedded: true)

  collapsibleId: (->
    "collapse-#{@get 'name'}"
  ).property()

  collapsibleHref: (->
    "##{@get 'collapsibleId'}"
  ).property()