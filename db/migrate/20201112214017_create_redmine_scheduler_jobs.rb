class CreateRedmineSchedulerJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_scheduler_jobs do |t|
      t.string :description
      t.string :kind
      t.string :time_expression
      t.text :code_to_execute

      t.timestamps
    end
  end
end
