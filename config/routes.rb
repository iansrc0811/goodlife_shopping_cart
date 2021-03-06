Rails.application.routes.draw do
  devise_for :users
  root :to => "products#index"
  resources :products do
    member do
      post :add_to_cart
    end
  end
  resources :orders do
    collection do
      get :get_line_items
    end
    member do
      post :remove_item
      post :edit_item
      post :checkout
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
