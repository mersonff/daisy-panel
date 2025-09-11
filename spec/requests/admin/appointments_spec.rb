require 'rails_helper'

RSpec.describe "Admin::Appointments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:appointment1) { create(:appointment, user: user, name: "Reunião 1") }
  let!(:appointment2) { create(:appointment, user: user, name: "Reunião 2") }
  let!(:other_user_appointment) { create(:appointment, user: other_user) }

  before do
    sign_in_user(user)
  end

  describe 'GET /admin/appointments' do
    it 'returns a success response' do
      get admin_appointments_path
      expect(response).to be_successful
    end

    it 'assigns only current user appointments' do
      get admin_appointments_path
      expect(assigns(:appointments)).to include(appointment1, appointment2)
      expect(assigns(:appointments)).not_to include(other_user_appointment)
    end

    it 'orders appointments by start time' do
      get admin_appointments_path
      appointments = assigns(:appointments).to_a
      expect(appointments).to eq([ appointment1, appointment2 ].sort_by(&:start_time))
    end

    it 'renders the index template' do
      get admin_appointments_path
      expect(response).to render_template(:index)
    end

    context 'with search parameter' do
      it 'filters appointments by name' do
        get admin_appointments_path, params: { search: 'Reunião 1' }
        expect(assigns(:appointments)).to include(appointment1)
        expect(assigns(:appointments)).not_to include(appointment2)
      end

      it 'is case insensitive' do
        get admin_appointments_path, params: { search: 'reunião 1' }
        expect(assigns(:appointments)).to include(appointment1)
      end
    end

    context 'with status filter' do
      let!(:past_appointment) { create(:appointment, :past, user: user) }
      let!(:ongoing_appointment) { create(:appointment, :ongoing, user: user) }
      let!(:upcoming_appointment) { create(:appointment, :upcoming, user: user) }

      it 'filters by upcoming status' do
        get admin_appointments_path, params: { status: 'upcoming' }
        appointments = assigns(:appointments)
        expect(appointments).to include(upcoming_appointment)
        expect(appointments).not_to include(past_appointment, ongoing_appointment)
      end

      it 'filters by past status' do
        get admin_appointments_path, params: { status: 'past' }
        appointments = assigns(:appointments)
        expect(appointments).to include(past_appointment)
        expect(appointments).not_to include(upcoming_appointment, ongoing_appointment)
      end

      it 'filters by ongoing status' do
        get admin_appointments_path, params: { status: 'ongoing' }
        appointments = assigns(:appointments)
        expect(appointments).to include(ongoing_appointment)
        expect(appointments).not_to include(past_appointment, upcoming_appointment)
      end
    end
  end

  describe 'GET /admin/appointments/:id' do
    it 'returns a success response' do
      get admin_appointment_path(appointment1)
      expect(response).to be_successful
    end

    it 'assigns the requested appointment' do
      get admin_appointment_path(appointment1)
      expect(assigns(:appointment)).to eq(appointment1)
    end

    it 'renders the show template' do
      get admin_appointment_path(appointment1)
      expect(response).to render_template(:show)
    end

    it 'redirects when appointment belongs to another user' do
      get admin_appointment_path(other_user_appointment)
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end

    it 'redirects when appointment does not exist' do
      get admin_appointment_path(id: 99999)
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end
  end

  describe 'GET /admin/appointments/new' do
    it 'returns a success response' do
      get new_admin_appointment_path
      expect(response).to be_successful
    end

    it 'assigns a new appointment' do
      get new_admin_appointment_path
      expect(assigns(:appointment)).to be_a_new(Appointment)
      expect(assigns(:appointment).user).to eq(user)
    end

    it 'renders the new template' do
      get new_admin_appointment_path
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /admin/appointments' do
    let(:valid_attributes) do
      {
        name: 'Nova Reunião',
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour
      }
    end

    let(:invalid_attributes) do
      {
        name: '',
        start_time: 1.day.from_now + 1.hour,
        end_time: 1.day.from_now
      }
    end

    context 'with valid parameters' do
      it 'creates a new appointment' do
        expect {
          post admin_appointments_path, params: { appointment: valid_attributes }
        }.to change(Appointment, :count).by(1)
      end

      it 'assigns the appointment to the current user' do
        post admin_appointments_path, params: { appointment: valid_attributes }
        expect(Appointment.last.user).to eq(user)
      end

      it 'redirects to the created appointment' do
        post admin_appointments_path, params: { appointment: valid_attributes }
        expect(response).to redirect_to(admin_appointment_path(Appointment.last))
      end

      it 'sets a success flash message' do
        post admin_appointments_path, params: { appointment: valid_attributes }
        expect(flash[:notice]).to eq('Compromisso foi criado com sucesso.')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new appointment' do
        expect {
          post admin_appointments_path, params: { appointment: invalid_attributes }
        }.to change(Appointment, :count).by(0)
      end

      it 'renders the new template' do
        post admin_appointments_path, params: { appointment: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'assigns the appointment with errors' do
        post admin_appointments_path, params: { appointment: invalid_attributes }
        expect(assigns(:appointment).errors).not_to be_empty
      end
    end

    context 'with conflicting appointment' do
      let!(:existing_appointment) do
        create(:appointment,
               user: user,
               start_time: 1.day.from_now.change(hour: 9, min: 0),
               end_time: 1.day.from_now.change(hour: 10, min: 0))
      end

      let(:conflicting_attributes) do
        {
          name: 'Conflicting Meeting',
          start_time: 1.day.from_now.change(hour: 9, min: 30),
          end_time: 1.day.from_now.change(hour: 10, min: 30)
        }
      end

      it 'does not create the appointment' do
        expect {
          post admin_appointments_path, params: { appointment: conflicting_attributes }
        }.to change(Appointment, :count).by(0)
      end

      it 'renders new template with error' do
        post admin_appointments_path, params: { appointment: conflicting_attributes }
        expect(response).to render_template(:new)
        expect(assigns(:appointment).errors[:base]).to include(/Conflito de horário/)
      end
    end
  end

  describe 'GET /admin/appointments/:id/edit' do
    it 'returns a success response' do
      get edit_admin_appointment_path(appointment1)
      expect(response).to be_successful
    end

    it 'assigns the requested appointment' do
      get edit_admin_appointment_path(appointment1)
      expect(assigns(:appointment)).to eq(appointment1)
    end

    it 'renders the edit template' do
      get edit_admin_appointment_path(appointment1)
      expect(response).to render_template(:edit)
    end

    it 'redirects when appointment belongs to another user' do
      get edit_admin_appointment_path(other_user_appointment)
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end
  end

  describe 'PATCH /admin/appointments/:id' do
    let(:new_attributes) do
      {
        name: 'Reunião Atualizada',
        start_time: 2.days.from_now,
        end_time: 2.days.from_now + 1.hour
      }
    end

    let(:invalid_attributes) do
      {
        name: '',
        start_time: 1.day.from_now + 1.hour,
        end_time: 1.day.from_now
      }
    end

    context 'with valid parameters' do
      it 'updates the requested appointment' do
        patch admin_appointment_path(appointment1), params: { appointment: new_attributes }
        appointment1.reload
        expect(appointment1.name).to eq('Reunião Atualizada')
      end

      it 'redirects to the appointment' do
        patch admin_appointment_path(appointment1), params: { appointment: new_attributes }
        expect(response).to redirect_to(admin_appointment_path(appointment1))
      end

      it 'sets a success flash message' do
        patch admin_appointment_path(appointment1), params: { appointment: new_attributes }
        expect(flash[:notice]).to eq('Compromisso foi atualizado com sucesso.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the appointment' do
        original_name = appointment1.name
        patch admin_appointment_path(appointment1), params: { appointment: invalid_attributes }
        appointment1.reload
        expect(appointment1.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch admin_appointment_path(appointment1), params: { appointment: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'redirects when appointment belongs to another user' do
      patch admin_appointment_path(other_user_appointment), params: { appointment: new_attributes }
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end
  end

  describe 'DELETE /admin/appointments/:id' do
    it 'destroys the requested appointment' do
      expect {
        delete admin_appointment_path(appointment1)
      }.to change(Appointment, :count).by(-1)
    end

    it 'redirects to the appointments list' do
      delete admin_appointment_path(appointment1)
      expect(response).to redirect_to(admin_appointments_path)
    end

    it 'sets a success flash message' do
      delete admin_appointment_path(appointment1)
      expect(flash[:notice]).to eq('Compromisso foi removido com sucesso.')
    end

    it 'redirects when appointment belongs to another user' do
      expect {
        delete admin_appointment_path(other_user_appointment)
      }.to change(Appointment, :count).by(0)
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end

    it 'redirects when appointment does not exist' do
      expect {
        delete admin_appointment_path(id: 99999)
      }.to change(Appointment, :count).by(0)
      expect(response).to redirect_to(admin_appointments_path)
      expect(flash[:alert]).to eq('Compromisso não encontrado.')
    end
  end

  context 'when user is not authenticated' do
    before do
      sign_out_user
    end

    it 'redirects to login for index' do
      get admin_appointments_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for show' do
      get admin_appointment_path(appointment1)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for new' do
      get new_admin_appointment_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for create' do
      post admin_appointments_path, params: { appointment: { name: 'Test' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for edit' do
      get edit_admin_appointment_path(appointment1)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for update' do
      patch admin_appointment_path(appointment1), params: { appointment: { name: 'Test' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for destroy' do
      delete admin_appointment_path(appointment1)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
