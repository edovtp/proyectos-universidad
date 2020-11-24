class MatchesController < ApplicationController
  def show
  end

  def index
    unless user_signed_in?
      redirect_to root_path, notice: 'Usted debe iniciar sesión para poder realizar match'
    else
      #@users = User.all.paginate(page: params[:page], per_page: 2)
      @user = User.find(params[:id])
      if params[:genero]
        if params[:genero] != "Todas" and params[:commune_id] != 'Todas'
          @users_previus = User.where("id != ? AND admin = false AND genero = ? AND commune_id = ?", @user.id, params[:genero], params[:commune_id])
        elsif params[:commune_id] != 'Todas'
          @users_previus = User.where("id != ? AND admin = false AND commune_id = ?", @user.id, params[:commune_id])
        elsif params[:genero] != 'Todas'
          @users_previus = User.where("id != ? AND admin = false AND genero = ?", @user.id, params[:genero])
        else
          @users_previus = User.where("id != " + @user.id.to_s + " AND admin = false")
        end
      else
        @users_previus = User.where("id != " + @user.id.to_s + " AND admin = false")
      end
      @matches_listos = Match.all
      @matches_request = MatchRequest.where("solicitante_id = " + @user.id.to_s)
      @users = []
      
      @users_previus.each do |user|
        repetido = false
        @matches_request.each do |match_request|
          if match_request.solicitado_id == user.id
            repetido = true
            break
          end
        end
        @matches_listos.each do |match|
          if match.user1_id == @user.id and match.user2_id == user.id
            repetido = true
            break
          elsif match.user2_id == @user.id and match.user1_id == user.id
            repetido = true
            break
          end
        end
        if not repetido
          @users << user
        end
      end
      @users = @users.shuffle!
      @users = @users.paginate(page: params[:page], per_page: 3)
        
    end
  end

  def show
    @user = User.find(params[:id])
    
    @pending_valuations = current_user.valuations.where("realizada = false")

    @current_date = DateTime.now.to_date

    # #Cada vez que entra a su perfil busca posibles match que se hayan hecho mutuamente por casualidad
    # @match_nuevos = MatchRequest.where('solicitado_id = ?', @user.id)
    # @match_nuevos.each do |m|
    #   @match_coincidentes = MatchRequest.where('solicitado_id = ? and solicitante_id = ?', m.solicitante_id, @user.id)
    #   if @match_coincidentes
    #     @match_coincidentes.each do |m2|
    #       match = Match.new(user1_id: m2.solicitante_id,
    #         user2_id: m2.solicitado_id,
    #         cita_realizada: false)
    #       match.save!
    #       m2.destroy
    #       m.destroy
    #     end
    #   end
    # end
    # Match que le han llegado como solicitud
    @match_nuevos = MatchRequest.where('solicitado_id = ?', @user.id)
    # Match que ya a concretado 
    @match_todos = Match.where('user1_id = ? or user2_id = ?', @user.id, @user.id)
  end

  def new
    @user = User.find(params[:id])
    @user_solicitud = User.find(params[:idsolicitado])
    @match_request = MatchRequest.new(
      solicitante_id: @user.id,
      solicitado_id: @user_solicitud.id
    )
    @match_request.save!
    notificacion = false
    @match_nuevos = MatchRequest.where('solicitado_id = ?', @user.id)
    @match_nuevos.each do |m|
      @match_coincidentes = MatchRequest.where('solicitado_id = ? and solicitante_id = ?', m.solicitante_id, @user.id)
      if @match_coincidentes
        @match_coincidentes.each do |m2|
          match = Match.new(user1_id: m2.solicitante_id,
            user2_id: m2.solicitado_id,
            cita_realizada: false)
          notificacion = true
          match.save!
          m2.destroy
          m.destroy
        end
      end
    end
    # Match que le han llegado como solicitud
    @match_nuevos = MatchRequest.where('solicitado_id = ?', @user.id)
    # Match que ya a concretado 
    @match_todos = Match.where('user1_id = ? or user2_id = ?', @user.id, @user.id)
    if notificacion
      redirect_to match_path(@user.id), notice: "Acabas de hacer MATCH, revisa la seccion de match para más informacion"
    else
      redirect_to match_path(@user.id)
    end
  end

  def accept_match
    if params[:aceptar] == "true"
      @user = User.find(params[:id])
      @match_request = MatchRequest.find(params[:id_matchrequest])
      match = Match.new(user1_id: @match_request.solicitante_id,
                user2_id: @match_request.solicitado_id,
                cita_realizada: false,
                local_id: nil)
      match.save!
      @match_request.destroy
      redirect_to perfil_path(@user.id)
    else
      @user = User.find(params[:id])
      @match_request = MatchRequest.find(params[:id_matchrequest])
      @match_request.destroy
      redirect_to perfil_path(@user.id)
    end
  end
end
