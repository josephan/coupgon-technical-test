Rails.application.routes.draw do

  post '/', to: 'pages#upload'
  # Homepage
  root to: 'pages#home'
end
