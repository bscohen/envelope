require 'constraints/api_constraints'

Envelope::Application.routes.draw do
  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :accounts do
        resources :mailboxes
      end

      resources :common_account_settings, :only => :index

      resources :users
    end
  end

  root to: 'main#index'
  match '*path' => 'main#index'





  ### OLD ###

  resources :labels

  resources :messages, :only => [:index, :new, :create] do
    get 'labels' => 'messages#labels', :on => :collection, :as => :labels
    get 'page/:page' => 'messages#index', :on => :collection, :as => :page
    get ':unified_mailbox' => 'messages#unified', :on => :collection, :constraints => { :unified_mailbox => /inbox|sent|trash/ }, :as => :unified_mailbox
    get ':unified_mailbox/page/:page' => 'messages#unified', :on => :collection
    get 'search' => 'messages#search', :on => :collection, :as => :search
  end


  resources :accounts do
    collection do
      get 'sync' => 'accounts#sync', :as => :sync
    end

    resources :mailboxes do
      resources :messages do
        get 'page/:page' => 'messages#index', :on => :collection, :as => :page

        resources :attachments

        put 'unread' => 'messages#unread', :as => :unread
        put 'flag' => 'messages#flag', :as => :flag

        post 'toggle_label' => 'messages#toggle_label', :as => :toggle_label
      end
    end
  end

  resources :contacts do
    get 'search' => 'contacts#search', :on => :collection, :as => :search
    get 'import' => 'contacts#import', :on => :collection, :as => :import
    post 'import' => 'contacts#import', :on => :collection, :as => :import
    resources :addresses
    resources :emails
    resources :phones
  end

  resources :users

  # login
  get 'login' => 'sessions#new', :as => :login
  post 'login' => 'sessions#create', :as => :login
  delete 'logout' => 'sessions#destroy', :as => :logout

  # forgot password
  get 'forgot-password' => 'users#forgot_password', :as => :forgot_password
  post 'forgot-password' => 'users#forgot_password', :as => :forgot_password
  get 'reset-password/:reset_password_token' => 'users#reset_password', :as => :reset_password

  # registration
  get 'signup' => 'users#new', :as => :signup
  get 'users/confirm/:id/:confirmation_token' => 'users#confirm', :as => :confirm_user
  get 'confirmation-email' => 'users#confirmation_email', :as => :confirmation_email

  root :to => redirect('/messages/inbox')
end
