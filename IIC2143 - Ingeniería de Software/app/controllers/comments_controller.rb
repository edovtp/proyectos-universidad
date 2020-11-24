class CommentsController < ApplicationController
  # Create
  def new
    if current_user
      @comentario = Comment.new
      @local = Local.find(params[:local_id])
      if current_user.id == @local.user_id
        redirect_to local_path(@local.id), notice: 'No puedes comentar en tu propio local'
      else
        render
      end
    else
      redirect_to root_path, notice: 'Debes iniciar sesión para comentar'
    end
  end

  def create
    comentario_params = params.require(:comment).permit(:contenido)
    comentario_params[:user_id] = current_user.id
    comentario_params[:local_id] = params[:local_id]
    @comentario = Comment.create(comentario_params)
    if @comentario.save
      redirect_to local_path(params[:local_id]), notice: 'El comentario ha sido agregado con éxito'
    else
      redirect_to local_path(params[:local_id]), notice: 'Ocurrió un error al crear el Comentario'
    end
  end

  # Read
  def index
    @comentarios = Comment.all
    render :layout => 'admin'
  end

  def show
    if user_signed_in? and current_user.id == params[:user_id].to_i
      @user = User.find(params[:user_id])
      @comentarios = Comment.where("user_id = #{@user.id}")
    else
      redirect_to root_path, notice: "No puedes acceder a esta página"
    end
  end

  def destroy
    @comentario = Comment.find(params[:id])
    @comentario.destroy
    if params[:perfil]
      redirect_to perfil_comentarios_path(current_user.id), notice: "El comentario ha sido eliminado con éxito"
      return
    end
    unless params[:admin]
      redirect_to local_path(params[:local_id]), notice: 'El comentario ha sido eliminado con éxito'
    else
      redirect_to comentarios_path, notice: 'El comentario ha sido eliminado con éxito'
    end
  end
end
