require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'


  root "periods#calendar"

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "sessions", only: [:create]

  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  get "/sign_up" => "clearance/users#new", as: "sign_up"
  resources :periods do
    collection do
      get :search
      get :calendar_search
    end
  end

  get "/session/duplicate" => "periods#duplicate", as: "duplicate_session"
  get "/period/change_status/:id" => "periods#change_status", as: "change_period_status"
  get "/admin/period/change_status/:id" => "admin/periods#change_status", as: "admin_change_period_status"
  get "/periods/calendar" => "periods#calendar", as: "sessions_calendar"
  get '/admin/users/select2_list_student' => 'admin/users#select2_list_student'
  get "/periods/calendar/drop/:id" => "periods#drop"
  match "/newmodal" => "periods#newmodal", :via => :get
  
  namespace :admin do
    resources :users
    resources :groups
    resources :profiles
    resources :periods
  end

  get '/redirect', to: 'gevents#redirect', as: 'redirect'
  get '/callback', to: 'gevents#callback', as: 'callback'
  get '/calendars', to: 'gevents#calendars', as: 'calendars'
  get '/events/:calendar_id', to: 'gevents#events', as: 'events', calendar_id: /[^\/]+/
  get '/new_events/:calendar_id/periods/:details', to: 'gevents#create', as: 'new_event', calendar_id: /[^\/]+/

end
