Rails.application.routes.draw do
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
    end
  end
  get "/session/duplicate" => "periods#duplicate", as: "duplicate_session"
  get "/period/change_status/:id" => "periods#change_status", as: "change_period_status"
  get "/periods/calendar" => "periods#calendar", as: "sessions_calendar"

  namespace :admin do
    resources :users
    resources :groups
    resources :profiles
    resources :periods
  end

  get '/redirect', to: 'examples#redirect', as: 'redirect'
  get '/callback', to: 'examples#callback', as: 'callback'
  get '/calendars', to: 'examples#calendars', as: 'calendars'
  get '/events/:calendar_id', to: 'examples#events', as: 'events', calendar_id: /[^\/]+/
  get '/new_events/:calendar_id/periods/:details', to: 'examples#new_event', as: 'new_event', calendar_id: /[^\/]+/

end
