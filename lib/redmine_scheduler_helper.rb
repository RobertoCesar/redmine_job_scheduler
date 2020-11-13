class RedmineSchedulerHelper

  def self.executa(metodo, tempo, funcao)
    s = Rufus::Scheduler.singleton
    Rails.logger.info "Método: " + metodo
    Rails.logger.info "Tempo: " + tempo
    Rails.logger.info "Função" + funcao
    c = 'executar_em'
    tempo = "5s"
   
    
    #if s.respond_to? metodo
    #  s.(metodo) tempo do
    #    instance_eval funcao
    #  end
    #end
  end
end
