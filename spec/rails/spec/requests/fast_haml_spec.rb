require 'rails_helper'

RSpec.describe 'FastHaml with Rails', type: :request do
  it 'renders views' do
    get '/books/hello'
    expect(response).to be_ok
    expect(response).to render_template('books/hello')
    expect(response).to render_template('layouts/application')
    expect(response.body).to include('<span>Hello, World</span>')
  end

  it 'renders views with variables' do
    get '/books/with_variables?title=nanika'
    expect(response).to be_ok
    expect(response).to render_template('books/with_variables')
    expect(response).to render_template('layouts/application')
    expect(response.body).to include('<p>nanika</p>')
  end
end
