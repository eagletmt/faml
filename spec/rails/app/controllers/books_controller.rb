class BooksController < ApplicationController
  def hello
  end

  def with_variables
    @book = Book.new(params.permit(:title))
  end

  def object_ref
    @book = Book.new(id: params[:id])
  end
end
