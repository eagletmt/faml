Rails.application.routes.draw do
  namespace :books do
    get :hello
    get :with_variables
    get :with_capture
    get :escaped
    get :preserve
  end
end
