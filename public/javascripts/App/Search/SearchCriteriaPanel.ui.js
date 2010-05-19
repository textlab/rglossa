App.Search.SearchCriteriaPanelUi = Ext.extend(Ext.form.FormPanel, {
  title: 'Search criteria',
  labelWidth: 100,
  labelAlign: 'left',
  layout: 'form',
  tbar: {
    xtype: 'toolbar',
    items: [{
      text: 'Add language',
      icon: urlRoot + 'images/add.png',
      cls: 'x-btn-text-icon',
      ref: '../addLanguageButton'
    //}, '-', {
      //text: 'Save search',
      //icon: urlRoot + 'images/disk.png'
    //}, {
      //text: 'Saved searches',
      //icon: urlRoot + 'images/folder_explore.png'
    }, '-', {
      text: 'Reset form',
      icon: urlRoot + 'images/cancel.png'
    }, '-', {
      text: '<b>Search</b>',
      icon: urlRoot + 'images/zoom.png'
    }]
  },

  initComponent: function() {
    App.Search.SearchCriteriaPanelUi.superclass.initComponent.call(this);
  }
});

