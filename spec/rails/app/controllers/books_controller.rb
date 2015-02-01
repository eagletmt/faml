class BooksController < ApplicationController
  def hello
  end

  def with_variables
    @book = Book.new(params.permit(:title))
  end
end
