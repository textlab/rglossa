Rglossa::Engine.routes.draw do
  devise_for :users, :class_name => "Rglossa::User", module: :devise

  root :to => 'home#index'

  resources :corpora, :metadata_values

  resources :metadata_categories do
    resources :metadata_values
  end

  namespace :search_engines do
    # Add more search types to the resource list as they are implemented, e.g.
    # resources :cwb_searches, :corpuscle_searches, :annis2_searches do
    resources :cwb_searches do
      collection do
        post 'query'

        # FIXME: These don't belong here
        get 'corpora_list'
        get 'corpus_info'
      end

      member do
        get 'results'
      end
    end
  end

end
