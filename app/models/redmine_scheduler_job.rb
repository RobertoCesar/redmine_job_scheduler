class RedmineSchedulerJob < ActiveRecord::Base
  validate :time_expression_is_valid

  def time_expression_is_valid
    begin
      if self.kind == "cron"
        Rufus::Scheduler.parse_cron(self.time_expression)
      end
    rescue ArgumentError
      # desativa job
      errors.add(:time_expression, ' não é uma expressão cron válida!')
    end
    
    begin
      if self.kind != "cron"
        Rufus::Scheduler.parse_duration(self.time_expression)
      end
    rescue ArgumentError
      errors.add(:time_expression, ' não é uma duração válida!')
    end
  end


end
