class SphinxWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    system 'rake ts:index'
  end
end
