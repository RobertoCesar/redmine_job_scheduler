require 'rufus-scheduler'
require_relative 'app/models/redmine_scheduler_job.rb'
require_relative 'app/controllers/redmine_scheduler_jobs_controller.rb'


Redmine::Plugin.register :redmine_scheduler do
  name 'Redmine Scheduler plugin'
  author 'Roberto Tavares'
  description 'Allows the configuration of jobs to close Issues according to the given settings'
  version '0.0.1'
  url 'https://github.com/RobertoCesar/RedmineCloseIssueScheduler'
  author_url 'https://github.com/RobertoCesar/RedmineCloseIssueScheduler'
  #settings default: {'empty' =>  true}, partial: 'settings/redmine_scheduler'
  menu :admin_menu, :scheduler, { controller: 'redmine_scheduler_jobs', action: 'index' }, caption: 'Redmine Scheduler'

  #exetuta todos os jobs
  RedmineSchedulerJobsController::executaTodosOsJobs
end

