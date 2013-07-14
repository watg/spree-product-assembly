Spree::Core::Engine.routes.append do

  namespace :admin do
    resources :products do

      resources :variants do
        resources :parts, :controller => 'variant_parts' do
          member do
            post :select
            post :remove
            post :set_count
          end
          collection do
            post :available
            post :available_parts
            get  :selected
          end
        end
      end

      resources :parts, :controller => 'product_parts' do
        member do
          post :select
          post :remove
          post :set_count
        end
        collection do
          post :available
          post :available_parts
          get  :selected
        end
      end

    end
  end
end
