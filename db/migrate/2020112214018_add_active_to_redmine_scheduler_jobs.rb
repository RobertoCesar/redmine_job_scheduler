class AddActiveToRedmineSchedulerJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :redmine_scheduler_jobs, :active, :boolean
    add_column :redmine_scheduler_jobs, :last_execution_id, :string
    add_column :redmine_scheduler_jobs, :current_execution_id, :string
  end
end

