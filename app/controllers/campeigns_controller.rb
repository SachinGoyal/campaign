class CampeignsController < ApplicationController
  before_action :set_campeign, only: [:show, :edit, :update, :destroy]

  # GET /campeigns
  # GET /campeigns.json
  def index
    @campeigns = Campeign.all
  end

  # GET /campeigns/1
  # GET /campeigns/1.json
  def show
  end

  # GET /campeigns/new
  def new
    @campeign = Campeign.new
  end

  # GET /campeigns/1/edit
  def edit
  end

  # POST /campeigns
  # POST /campeigns.json
  def create
    binding.pry
    @campeign = current_user.campeigns.build(campeign_params)
    respond_to do |format|
      if @campeign.save
        format.html { redirect_to [current_user,@campeign], notice: 'Campeign was successfully created.' }
        format.json { render :show, status: :created, location: @campeign }
      else
        format.html { render :new }
        format.json { render json: @campeign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campeigns/1
  # PATCH/PUT /campeigns/1.json
  def update
    respond_to do |format|
      if @campeign.update(campeign_params)
        format.html { redirect_to @campeign, notice: 'Campeign was successfully updated.' }
        format.json { render :show, status: :ok, location: @campeign }
      else
        format.html { render :edit }
        format.json { render json: @campeign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campeigns/1
  # DELETE /campeigns/1.json
  def destroy
    @campeign.destroy
    respond_to do |format|
      format.html { redirect_to user_campeigns_url(current_user), notice: 'Campeign was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campeign
      @campeign = Campeign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campeign_params
      params.require(:campeign).permit(:user_id, :name, :description, :status, :created_by, :updated_by)
    end
end
