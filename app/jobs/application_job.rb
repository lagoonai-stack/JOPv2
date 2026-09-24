class ApplicationJob < ActiveJob::Base
  # Retentar automaticamente jobs que encontrarem deadlock
  # retry_on ActiveRecord::Deadlocked

  # A maioria dos jobs pode ser descartada se os registros base não existem mais
  # discard_on ActiveJob::DeserializationError
end
