class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def create
    GenerateBooksJob.perform_later

    redirect_to :back, success: 'The books were generated successfully.'
  end
end
