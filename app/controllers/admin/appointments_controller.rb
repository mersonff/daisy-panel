class Admin::AppointmentsController < Admin::DashboardController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]

  def index
    @appointments = current_user.appointments
                                .includes(:user)
                                .ordered_by_start_time

    case params[:status]
    when "upcoming"
      @appointments = @appointments.upcoming
    when "past"
      @appointments = @appointments.past
    when "ongoing"
      @appointments = @appointments.ongoing
    end

    # Search functionality
    if params[:search].present?
      @appointments = @appointments.where("name ILIKE ?", "%#{params[:search]}%")
    end
  end

  def show
  end

  def new
    @appointment = current_user.appointments.build
  end

  def create
    @appointment = current_user.appointments.build(appointment_params)

    if @appointment.save
      redirect_to admin_appointment_path(@appointment),
                  notice: "Compromisso foi criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to admin_appointment_path(@appointment),
                  notice: "Compromisso foi atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @appointment.destroy
    redirect_to admin_appointments_path,
                notice: "Compromisso foi removido com sucesso."
  end

  private

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_appointments_path,
                alert: "Compromisso não encontrado."
  end

  def appointment_params
    params.require(:appointment).permit(:name, :start_time, :end_time)
  end
end
