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

  it 'escapes non-html_safe string' do
    uri = URI.parse('/books/with_variables')
    uri.query = URI.encode_www_form(title: '<script>alert(1)</script>')
    get uri.to_s
    expect(response).to be_ok
    expect(response).to render_template('books/with_variables')
    expect(response).to render_template('layouts/application')
    expect(response.body).to include('<a href="/books/hello">hello</a>')
    expect(response.body).to include('<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>')
  end
end
