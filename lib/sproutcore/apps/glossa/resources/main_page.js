// ==========================================================================
// Project:   Glossa - mainPage
// Copyright: ©2010 The Text Laboratory, University of Oslo
// ==========================================================================

sc_require('views/query_row');

/*globals Glossa */

// This page describes the main user interface for your application.
Glossa.mainPage = SC.Page.design({

  // The main pane is made visible on screen as soon as your app is loaded.
  // Add childViews to this pane for views to display immediately on page
  // load.
  mainPane: SC.MainPane.design({
    childViews: 'tabView'.w(),

    tabView: SC.TabView.design({
      items: [
        { title: 'Criteria', value: 'Glossa.searchView' },
        { title: 'Results', value: 'Glossa.resultsView' }
      ],
      itemTitleKey: 'title',
      itemValueKey: 'value',
      nowShowing: 'Glossa.searchView',

      init: function() {
        sc_super();
      }

    })

  })

});

// The content views of Glossa.mainPage.mainPane.tabView. These cannot be defined
// within Glossa.mainPage because it leads to infinite recursion if nowShowing
// is set (since Glossa.mainPage and all its child panels will be created then, including
// the TabView, which leads to setting of nowShowing, which leads to creation of Glossa.mainPage
// etc. ad infinitum...).
Glossa.searchView = SC.View.design({
  childViews: 'buttons queryRows'.w(),

  buttons: SC.View.design({
    layout: { left: 10, top: 10, width: 300, height: 45 },
    childViews: 'resetButton searchButton'.w(),

    resetButton: SC.ButtonView.design({
      layout: { width: 100 },
      title: 'Reset form',
      action: 'myMethod',
      target: 'MyApp.Controller'
    }),

    searchButton: SC.ButtonView.design({
      layout: { left: 110, width: 100 },
      title: 'Search',
      action: 'search',
      target: 'Glossa.searchController',
      isDefault: YES
    })
  }),

  queryRows: SC.ScrollView.design({
    layout: { top: 45, right: 0, bottom: 0, left: 0 },

    contentView: SC.CollectionView.design({
      contentBinding: 'Glossa.searchController.queries',

      // Each QueryRowView contains a horizontal sequence of query terms
      exampleView: Glossa.QueryRowView
    })
  })

});

Glossa.resultsView = SC.ScrollView.design({
  contentView: SC.ListView.design({
    layout: { top: 10, bottom: 10 },
    contentBinding: 'Glossa.searchResultsArrayController.arrangedObjects',
    contentValueKey: 'line',
    showAlternatingRows: YES,
    exampleView: SC.ListItemView.design({
      escapeHTML: NO
    })
  })
});
