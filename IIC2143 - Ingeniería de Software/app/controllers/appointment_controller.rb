class AppointmentController < ApplicationController
  def new
    @appointment = Appointment.new
    @user_id = params[:id]
  end

  def create
    appointment_params = params.require(:appointment).permit(:local_id, :fecha)
    appointment_params[:match_id] = params[:match_id]
    appointment_params[:solicitante_id] = params[:id]
    appointment = Appointment.new(appointment_params)
    if appointment.save
      redirect_to match_info_path(params[:id]), notice: 'El local y fecha de cita se han propuesto con éxito'
    else
      redirect_to new_appointment_path(params[:id], match_id: params[:match_id]), notice: 'Ocurrió un error,
      inténtalo nuevamente'
    end
  end

  def accept
    if params[:accept] == "true"
      @user = User.find(params[:id])
      @appointment = Appointment.find(params[:appointment_id])
      match = Match.find(@appointment.match_id)
      match.update(:cita_realizada => true, :local_id =>@appointment.local_id)

      @fecha = @appointment.fecha
      if match.user1_id == @user.id
        solicitado_id = match.user1_id
        solicitante_id = match.user2_id
      else
        solicitado_id = match.user2_id
        solicitante_id = match.user1_id
      end
      local = Local.find(@appointment.local_id)
      valuation1 = Valuation.new(user_id: solicitante_id,
        local_id: @appointment.local_id,
        local_name: local.nombre,
        lucky_id: solicitado_id,
        fecha: @fecha,
        nombre: User.find(solicitado_id).nombre)
      valuation1.save

      valuation2 = Valuation.new(user_id: solicitado_id,
        local_id: @appointment.local_id,
        local_name: local.nombre,
        fecha: @fecha,
        lucky_id: solicitante_id,
        nombre: User.find(solicitante_id).nombre)
      if valuation2.save
        trash = Appointment.where("match_id = ?", match.id)
        trash.destroy_all
        redirect_to perfil_valuations_path(@user.id), notice: 'La cita ha sido aceptada con éxito'
      end
    elsif params[:accept] == "false"
      @user = User.find(params[:id])
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.destroy
      redirect_to match_info_path(@user.id), notice: 'La cita ha sido rechazada con éxito'
    end
  end
end
