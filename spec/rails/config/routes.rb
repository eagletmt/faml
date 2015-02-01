Rails.application.routes.draw do
  namespace :books do
    get :hello
    get :with_variables
    get :with_partial
  end
end
