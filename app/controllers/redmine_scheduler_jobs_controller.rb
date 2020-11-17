class RedmineSchedulerJobsController < ApplicationController
  before_action :set_redmine_scheduler_job, only: [:show, :edit, :update, :destroy]
#  before_action :autoriza_admin
  before_action :define_tipos_de_job
  
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
        #format.html { redirect_to @redmine_scheduler_job, notice: 'Job criado com sucesso.' }
        format.html { redirect_to redmine_scheduler_jobs_path, notice: 'Job criado com sucesso.' }
        format.json { render :show, status: :created, location: @redmine_scheduler_job }
        RedmineSchedulerJobsController::executaJob(@redmine_scheduler_job)
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
        format.html { redirect_to redmine_scheduler_jobs_path, notice: 'Job atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @redmine_scheduler_job }
        
        RedmineSchedulerJobsController::paraJob(@redmine_scheduler_job)
        RedmineSchedulerJobsController::executaJob(@redmine_scheduler_job)
      else
        format.html { render :edit }
        format.json { render json: @redmine_scheduler_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redmine_scheduler_jobs/1
  # DELETE /redmine_scheduler_jobs/1.json
  def destroy
    RedmineSchedulerJobsController::paraJob(@redmine_scheduler_job)
    @redmine_scheduler_job.destroy
    respond_to do |format|
      format.html { redirect_to redmine_scheduler_jobs_url, notice: 'Job excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_redmine_scheduler_job
      @redmine_scheduler_job = RedmineSchedulerJob.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def redmine_scheduler_job_params
      params.require(:redmine_scheduler_job).permit(:description, :kind, :time_expression, :code_to_execute, :active)
    end
  
  def autoriza_admin
    unless User.current.admin?
      render_403
    end
  end
  
  def self.executaJob(job)
    #só executa jobs se a variável REDMINE_MANAGER=true
    if defined? ENV['REDMINE_MANAGER']
      if ENV['REDMINE_MANAGER'] === true
        Rails.logger.info "Variavel REDMINE_MANAGER = true"
      else
        Rails.logger.info "Variavel REDMINE_MANAGER = false"
      end
    else
      Rails.logger.info "Variável REDMINE_MANAGER não está setada."
    end
    
    
    begin
      if(job.active)
      #Instancia o rufusScheduler
        return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'
        s = Rufus::Scheduler.singleton
        Rails.logger.info "Job #{job.id} - #{job.description}"
        Rails.logger.info "Metodo #{job.kind}"
        Rails.logger.info "Tempo #{job.time_expression}"
        Rails.logger.info "Função: #{job.code_to_execute}"
        
        if s.respond_to? job.kind
          rJob = s.send job.kind, job.time_expression, :job => true do
            instance_eval job.code_to_execute
          end
          Rails.logger.info "Id do job no RufusScheduler: #{rJob.id}"
          unless job.current_execution_id == nil
            job.last_execution_id = job.current_execution_id
          end
          job.current_execution_id = rJob.id
          job.save
          return rJob
        else
          Rails.logger.error "Erro ao executar job #{job.description}: é possível que algum campo do job esteja malformado."
        end
      end
    rescue ArgumentError
      Rails.logger.error "Erro ao executar job #{job.description}: é possível que algum campo do job esteja malformado."
    end
  end

  def self.paraJob(job)
    if(job.current_execution_id != nil )
      s = Rufus::Scheduler.singleton
      if s.scheduled?(job.current_execution_id)
        s.unschedule(job.current_execution_id)
        job.last_execution_id = job.current_execution_id
        job.current_execution_id = nil
      else
        Rails.logger.error "Erro ao tentar parar o job #{job.description}: o job não está agendado."
      end
    else
      Rails.logger.error "Erro ao parar job #{job.description}: o job não está ativo ou não está em execução."
    end
  end

  def self.executaTodosOsJobs
    jobs = RedmineSchedulerJob.all
    jobs.each do |j|
      RedmineSchedulerJobsController::executaJob(j)
    end
  end

end
