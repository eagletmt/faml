class BooksController < ApplicationController
  def hello
  end

  def with_variables
    @book = Book.new(title: params[:title])
  end
end
