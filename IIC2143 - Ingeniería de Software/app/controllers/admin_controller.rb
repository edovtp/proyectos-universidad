class AdminController < ApplicationController
  layout "admin"

  def aceptar_locales
      @locales_pendientes = Local.where("aceptado = ?", false)
  end

  def aceptar_local
    @local = Local.find(params[:local_id])
    @local.update(:aceptado => true)
    redirect_to admin_aceptar_locales_path, notice: 'El local ha sido aceptado con éxito'
  end

  def ver_locales
    @locales = Local.where("aceptado = ?", true)
    render 'locales'
  end

  def eliminar_local
    aceptado = params[:aceptado]
    @local = Local.find(params[:local_id])
    @local.destroy
    if aceptado == "si"
      redirect_to admin_locales_path, notice: 'El local ha sido eliminado con éxito'
    elsif aceptado == "no"
      redirect_to admin_aceptar_locales_path, notice: 'El local ha sido rechazado con éxito'
    end
  end
end
