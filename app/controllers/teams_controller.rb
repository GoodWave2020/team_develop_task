class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if current_user == @team.owner
      if @team.update(team_params)
        redirect_to @team, notice: I18n.t('views.messages.update_team')
      else
        flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
        render :edit
      end
    else
      redirect_to team_url(params[:team_id]), notice: '本人もしくはオーナーしか編集できません'
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def change_owner
    @team = Team.friendly.find(params[:team_id])
    if current_user == @team.owner
      @team.owner = User.find(params[:user_id])
      @team.save
      NoticeChangeOwnerMailer.notice_change_owner_mail(@team).deliver
      redirect_to @team, notice: 'リーダーを変更しました'
    else
      redirect_to @team, notice: '権限がありません'
    end
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
