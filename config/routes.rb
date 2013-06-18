Spree::Core::Engine.routes.append do

  namespace :admin do
    resources :products do

      resources :variants do
        resources :parts, :controller => 'variants/parts' do
          member do
            post :select
            post :remove
            post :set_count
          end
          collection do
            post :available
            get  :selected
          end
        end
      end

      resources :parts do
        member do
          post :select
          post :remove
          post :set_count
        end
        collection do
          post :available
          get  :selected
        end
      end

    end
  end
end
