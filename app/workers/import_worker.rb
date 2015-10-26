class PrintWorker
  include Sidekiq::Worker

  def perform(str)
    puts str
  end
end