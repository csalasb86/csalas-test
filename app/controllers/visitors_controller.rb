class VisitorsController < ApplicationController
  def index
    @routes = Route.order(:ends_at).all
  end

  def assign
    SchedulerService.call
    redirect_to root_path, notice: 'Rutas asignadas correctamente'
  end
end
