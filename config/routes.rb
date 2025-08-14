Rails.application.routes.draw do
  resource :referral, only: [:show] do
    collection do
      post :apply
    end
  end

  # Devise routes
  devise_for :users

  # Root route
  root 'home#index'

  # Static pages
  get 'about', to: 'home#about'
  get 'contact', to: 'home#contact'
  get 'help', to: 'home#help'
  get 'terms', to: 'home#terms'
  get 'privacy', to: 'home#privacy'
  get 'faq', to: 'home#faq'

  # Products
  resources :products, only: [:index, :show] do
    member do
      post 'add_to_cart'
      post 'add_to_wishlist'
      delete 'remove_from_wishlist'
    end
    collection do
      get 'search'
      get 'category/:id', to: 'products#category', as: :category
      get 'brand/:brand', to: 'products#brand', as: :brand
      get 'featured'
      get 'new-arrivals'
      get 'on-sale'
    end
    resources :reviews, only: [:new, :create]
  end

  # Categories
  resources :categories, only: [:index, :show]

  # Cart
  resource :cart, only: [:show, :update, :destroy], controller: 'cart' do
    member do
      post 'add_item'
      patch 'update_item'
      delete 'remove_item'
      post 'apply_coupon'
      delete 'remove_coupon'
    end
  end

  # Wishlist
  resource :wishlist, only: [:show], controller: 'wishlist'

  # Orders
  resources :orders, only: [:index, :show, :create] do
    member do
      post 'cancel'
      post 'confirm_receipt'
    end
  end

  # Checkout
  resource :checkout, only: [:show, :update], controller: 'checkout' do
    member do
      get 'shipping'
      get 'payment'
      get 'confirmation'
    end
  end

  # User profile
  resource :profile, only: [:show, :edit, :update], controller: 'profile' do
    member do
      get 'orders'
      get 'wishlist'
      get 'reviews'
      get 'addresses'
    end
  end

  # Reward wallet
  resource :reward_wallet, only: [:show], controller: 'reward_wallet'

  # Addresses
  resources :addresses, except: [:show]

  # Reviews
  resources :reviews, only: [:update, :destroy]

  # Stores
  resources :stores, only: [:index, :show] do
    member do
      get 'products'
      get 'reviews'
    end
  end

  # Customer namespace
  namespace :customer do
    get 'dashboard', to: 'dashboard#index'
    resources :orders, only: [:index, :show] do
      member do
        post 'cancel'
        post 'request_return'
      end
    end
    resources :reviews, only: [:index, :create, :update, :destroy]
    resources :addresses
  end

  # Seller namespace
  namespace :seller do
    get 'dashboard', to: 'dashboard#index'
    
    resource :store, except: [:destroy] do
      member do
        patch 'verify'
        patch 'suspend'
        patch 'activate'
      end
    end
    
    resources :products do
      member do
        patch 'toggle_status'
        patch 'toggle_featured'
      end
      resources :product_images, only: [:create, :destroy] do
        member do
          patch 'reorder'
        end
      end
      resources :product_variants, except: [:show]
    end
    
    resources :orders, only: [:index, :show] do
      member do
        patch 'confirm'
        patch 'process_order'
        patch 'ship'
        patch 'deliver'
        patch 'cancel'
      end
    end
    
    resources :inventory, only: [:index, :update]
    resources :analytics, only: [:index]
    resources :promotions, except: [:show]
  end

  # Admin namespace
  namespace :admin do
    get "mlm/index"
    get "mlm/show"
    get "mlm/payout"
    get "rewards/index"
    get 'dashboard', to: 'dashboard#index'
    
    resources :users do
      member do
        patch 'verify'
        patch 'suspend'
        patch 'activate'
        patch 'change_role'
      end
    end
    
    resources :stores do
      member do
        patch 'verify'
        patch 'suspend'
        patch 'activate'
      end
    end
    
    resources :categories do
      member do
        patch 'toggle_status'
      end
    end
    
    resources :products do
      member do
        patch 'toggle_status'
        patch 'toggle_featured'
      end
    end
    
    resources :orders, only: [:index, :show] do
      member do
        patch 'update_status'
        patch 'refund'
      end
    end
    
    resources :coupons
    resources :reports, only: [:index]
    resources :settings, only: [:index, :update]
    resources :rewards, only: [:index] do
      collection do
        get :edit
        patch :update
        post :award_points
      end
    end
    resources :mlm, only: [:index, :show] do
      collection do
        post :payout
        patch :process_payout
      end
    end
  end

  # API namespace
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      resources :stores, only: [:index, :show]
      resources :orders, only: [:create, :show]
    end
  end

  # Health check
  get 'health', to: 'health#check'

  # Catch all route for 404
  match '*path', to: 'application#not_found', via: :all
end
