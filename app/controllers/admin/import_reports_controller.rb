class Admin::ImportReportsController < Admin::DashboardController
  before_action :authenticate_user!
  before_action :set_import_report, only: [ :show ]

  def index
    @import_reports = current_user.import_reports.recent.limit(20)
  end

  def show
    @errors = @import_report.errors_list
  end

  def latest
    @import_report = current_user.import_reports.recent.first

    if @import_report
      redirect_to admin_import_report_path(@import_report)
    else
      redirect_to admin_clients_path, notice: "Nenhuma importação encontrada."
    end
  end

  private

  def set_import_report
    @import_report = current_user.import_reports.find(params[:id])
  end
end
