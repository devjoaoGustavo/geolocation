Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'ip_locations', to: 'ip_locations#search'
    end
  end
end
