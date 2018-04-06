class SlackJob < ApplicationJob
  queue_as :default

  def perform(message: ,random:)
  end
end
