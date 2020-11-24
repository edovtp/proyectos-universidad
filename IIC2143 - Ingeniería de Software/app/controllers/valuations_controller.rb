class ValuationsController < ApplicationController
  def edit
    if current_user
      @valuation = Valuation.find(params[:id])
      @local = Local.find(@valuation.local_id)
      valoraciones_pendientes = current_user.valuations.where("realizada = false AND local_id = #{@local.id}")
      if valoraciones_pendientes.include? @valuation
        render
      else
        redirect_to root_path, notice: "No puedes acceder a esta página"
      end
    else
      redirect_to root_path, notice: "No puedes acceder a esta página"
    end
  end

  def update
    @valuation = Valuation.find(params[:id])
    @local = Local.find(params[:local_id])
    puntuacion = params.require(:valuation).permit(:valuation)[:valuation]
    if @valuation.update(puntuacion: puntuacion, realizada: true)
      redirect_to local_path(@local.id), notice: "La valoración ha sido agregada con éxito"
    else
      redirect_to perfil_path(current_user.id), notice: "Ocurrió un error al agregar la valoración"
    end
  end

  def destroy
    @valuation = Valuation.find(params[:id])
    @valuation.destroy
    redirect_to perfil_path(current_user.id), notice: "Lamentamos que la cita no haya ocurrido, más suerte para la próxima"
  end
end
