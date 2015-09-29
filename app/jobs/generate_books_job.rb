class GenerateBooksJob < ActiveJob::Base
  queue_as :default

  def perform
    Book.generate
  end
end
