class GenerateQuotesJob < ActiveJob::Base
  queue_as :default

  def perform
    Quote.generate
  end
end
