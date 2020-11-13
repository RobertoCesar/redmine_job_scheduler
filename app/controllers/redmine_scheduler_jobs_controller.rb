class RedmineSchedulerJobsController < ApplicationController
  before_action :set_redmine_scheduler_job, only: [:show, :edit, :update, :destroy]
  before_action :autoriza_admin, :define_tipos_de_job
  
  def define_tipos_de_job
    @jobTipos = ['in','at','every','interval','cron']
  end

  # GET /redmine_scheduler_jobs
  # GET /redmine_scheduler_jobs.json
  def index
    @redmine_scheduler_jobs = RedmineSchedulerJob.all
  end

  # GET /redmine_scheduler_jobs/1
  # GET /redmine_scheduler_jobs/1.json
  def show
  end

  # GET /redmine_scheduler_jobs/new
  def new
    @redmine_scheduler_job = RedmineSchedulerJob.new
  end

  # GET /redmine_scheduler_jobs/1/edit
  def edit
  end

  # POST /redmine_scheduler_jobs
  # POST /redmine_scheduler_jobs.json
  def create
    @redmine_scheduler_job = RedmineSchedulerJob.new(redmine_scheduler_job_params)

    respond_to do |format|
      if @redmine_scheduler_job.save
        format.html { redirect_to @redmine_scheduler_job, notice: 'Redmine scheduler job was successfully created.' }
        format.json { render :show, status: :created, location: @redmine_scheduler_job }
      else
        format.html { render :new }
        format.json { render json: @redmine_scheduler_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /redmine_scheduler_jobs/1
  # PATCH/PUT /redmine_scheduler_jobs/1.json
  def update
    respond_to do |format|
      if @redmine_scheduler_job.update(redmine_scheduler_job_params)
        format.html { redirect_to @redmine_scheduler_job, notice: 'Redmine scheduler job was successfully updated.' }
        format.json { render :show, status: :ok, location: @redmine_scheduler_job }
      else
        format.html { render :edit }
        format.json { render json: @redmine_scheduler_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redmine_scheduler_jobs/1
  # DELETE /redmine_scheduler_jobs/1.json
  def destroy
    @redmine_scheduler_job.destroy
    respond_to do |format|
      format.html { redirect_to redmine_scheduler_jobs_url, notice: 'Redmine scheduler job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_redmine_scheduler_job
      @redmine_scheduler_job = RedmineSchedulerJob.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def redmine_scheduler_job_params
      params.require(:redmine_scheduler_job).permit(:description, :kind, :time_expression, :code_to_execute)
    end
  def autoriza_admin
    unless User.current.admin?
      render_403
    end
  end
  
  def self.executaJob(job)
    #Instancia o rufusScheduler
    s = Rufus::Scheduler.singleton
    Rails.logger.info "Job #{job.id} - #{job.description}"
    Rails.logger.info "Metodo #{job.kind}"
    Rails.logger.info "Tempo #{job.time_expression}"
    Rails.logger.info "Função: #{job.code_to_execute}"
    
    if s.respond_to? job.kind
      rJob = s.send job.kind, job.time_expression, :job => true do
        instance_eval job.code_to_execute
      end
      Rails.logger.info "Id do job no RufusScheduler: #{rJob}"
    end
  end
end
