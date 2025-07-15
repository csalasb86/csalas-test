# frozen_string_literal: true

class VisitorsController < ApplicationController
  def index
    @routes = Route.order(:ends_at).all
  end

  def assign
    SchedulerService.call
    redirect_to root_path, notice: I18n.t('notices.routes_assigned')
  end
end
