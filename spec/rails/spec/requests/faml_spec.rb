# frozen-string-literal: true
require 'rails_helper'

RSpec.describe 'Faml with Rails', type: :request do
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

  it 'does not escape object which returns html_safe string by to_s' do
    get '/books/with_variables?title=nanika'
    expect(response.body).to include('<span>nanika</span>')
  end

  it 'works with capture method' do
    get '/books/with_capture'
    expect(response).to be_ok
    expect(response.body).to include("<div><div>\n<p>Hello</p>\n</div>\n</div>\n")
  end

  it 'works with :escaped filter' do
    get '/books/escaped'
    expect(response).to be_ok
    expect(response.body).to include('&lt;marquee&gt;escape me&lt;/marquee&gt;')
  end

  describe 'object reference' do
    it 'works with new object' do
      get '/books/object_ref'
      expect(response).to be_ok
      expect(response.body).to include("<div class='book' id='book_new'>")
    end

    it 'works with id' do
      get '/books/object_ref', id: 123
      expect(response).to be_ok
      expect(response.body).to include("<div class='book' id='book_123'>")
    end
  end

  describe 'preserve helper' do
    around do |example|
      extend_helpers = Faml::Engine.options[:extend_helpers]
      Faml::Engine.options[:extend_helpers] = true
      example.run
      Faml::Engine.options[:extend_helpers] = extend_helpers
    end

    it 'returns html_safe string' do
      get '/books/preserve'
      expect(response).to be_ok
      expect(response.body).to include('<b>preserve&#x000A;me</b>')
    end
  end

  describe 'compile time errors' do
    describe HamlParser::Error do
      it 'has proper backtrace' do
        expect { get '/books/syntax_error' }.to raise_error { |e|
          expect(e.backtrace[0]).to end_with('app/views/books/syntax_error.html.haml:2')
        }
      end
    end

    describe HamlParser::IndentTracker::IndentMismatch do
      it 'has proper backtrace' do
        expect { get '/books/indent_error' }.to raise_error { |e|
          expect(e.backtrace[0]).to end_with('app/views/books/indent_error.html.haml:3')
        }
      end
    end

    describe Faml::UnparsableRubyCode do
      it 'has proper backtrace' do
        expect { get '/books/unparsable' }.to raise_error { |e|
          expect(e.backtrace[0]).to end_with('app/views/books/unparsable.html.haml:2')
        }
      end
    end

    describe Faml::FilterCompilers::NotFound do
      it 'has proper backtrace' do
        expect { get '/books/filter_not_found' }.to raise_error { |e|
          expect(e.backtrace[0]).to end_with('app/views/books/filter_not_found.html.haml:2')
        }
      end
    end

    describe Faml::TextCompiler::InvalidInterpolation do
      it 'has proper backtrace' do
        expect { get '/books/invalid_interpolation' }.to raise_error { |e|
          expect(e.backtrace[0]).to end_with('app/views/books/invalid_interpolation.html.haml:3')
        }
      end

      context 'inside filter' do
        it 'has proper backtrace' do
          expect { get '/books/filter_invalid_interpolation' }.to raise_error { |e|
            expect(e.backtrace[0]).to end_with('app/views/books/filter_invalid_interpolation.html.haml:4')
          }
        end
      end
    end
  end
end
