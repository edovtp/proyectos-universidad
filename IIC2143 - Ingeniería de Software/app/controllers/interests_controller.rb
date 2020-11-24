class InterestsController < ApplicationController
  layout "admin"

  # Create
  def new
    @gusto = Interest.new
  end

  def create
    gusto_params = params.require(:interest).permit(:nombre, :descripcion)
    @gusto = Interest.create(gusto_params)

    if @gusto.save
      redirect_to gustos_path, notice: 'Gusto creado con éxito'
    else
      redirect_to new_gusto_path, notice: 'Ocurrió un error al crear el gusto'
    end
  end

  # Read

  def index
    @gustos = Interest.all
  end

  def show
    @gusto = Interest.find(params[:id])
  end

  # Update

  def edit
    @gusto = Interest.find(params[:id])
  end

  def update
    gusto_params = params.require(:interest).permit(:nombre, :descripcion)
    @gusto = Interest.find(params[:id])

    if @gusto.update(gusto_params)
      redirect_to gusto_path(@gusto.id), notice: 'Gusto editado con éxito'
    else
      redirect_to gusto_path(@gusto.id), notice: 'Ocurrió un error al editar el gusto'
    end
  end

  # Delete

  def destroy
    @gusto = Interest.find(params[:id])
    @gusto.destroy
    redirect_to gustos_path, notice: 'Gusto eliminado con éxito'
  end

end
