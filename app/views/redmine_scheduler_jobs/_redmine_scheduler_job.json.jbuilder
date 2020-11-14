json.extract! redmine_scheduler_job, :id, :description, :kind, :time_expression, :code_to_execute, :created_at, :updated_at, :active
json.url redmine_scheduler_job_url(redmine_scheduler_job, format: :json)
