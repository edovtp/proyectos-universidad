class CommunesController < ApplicationController

  layout "admin"

  # Create
  def new
    @comuna = Commune.new
  end

  def create
    commune_params = params.require(:commune).permit(:nombre)
    @comuna = Commune.create(commune_params)

    if @comuna.save
      redirect_to comunas_path, notice: 'Comuna creada con éxito'
    else
      redirect_to new_comuna_path, notice: 'Ocurrió un error al crear la commune'
    end
  end

  # Read

  def index
    @comunas = Commune.all
  end

  def show
    @comuna = Commune.find(params[:id])
  end

  # Update

  def edit
    @comuna = Commune.find(params[:id])
  end

  def update
    commune_params = params.require(:commune).permit(:nombre)
    @comuna = Commune.find(params[:id])

    if @comuna.update(commune_params)
      redirect_to comuna_path(@comuna.id), notice: 'Comuna editada con éxito'
    else
      redirect_to comuna_path(@comuna.id), notice: 'Ocurrió un error al editar la commune'
    end
  end

  # Delete

  def destroy
    @comuna = Commune.find(params[:id])
    @comuna.destroy
    redirect_to comunas_path, notice: 'Comuna eliminada con éxito'
  end

end
