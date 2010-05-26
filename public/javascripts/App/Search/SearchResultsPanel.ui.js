App.Search.SearchResultsPanelUi = Ext.extend(Ext.grid.GridPanel, {
  title: 'Search results',
  columns: [{
    id: 'line',
    xtype: 'templatecolumn',
    header: 'Result',
    dataIndex: 'line',
    tpl: new Ext.XTemplate('<tpl for="line">{.}<br></tpl>')
  }],
  autoExpandColumn: 'line',
  bbar: {
    xtype: 'paging'
  },
  ref: 'searchResultsPanel',

  initComponent: function() {
    // Remember to create a new store for each results panel
    var store = new Ext.data.JsonStore({
      fields: ['line'],
      url: urlRoot + 'searches/query',
      totalProperty: 'querySize',
      root: 'data'
    });
    this.store = store;

    App.Search.SearchResultsPanelUi.superclass.initComponent.call(this);

    // connect pager to the grids datastore
    // bindStore() undocumented ?
    this.getBottomToolbar().bindStore(store);
    this.getBottomToolbar().pageSize = App.Controller.resultPagerSize;
  }
});
