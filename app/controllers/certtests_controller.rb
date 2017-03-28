class CerttestsController < ApplicationController
  before_action :set_certtest, only: [:show, :edit, :update, :destroy]

  # GET /certtests
  # GET /certtests.json
  def index
    @certtests = Certtest.all
  end

  # GET /certtests/1
  # GET /certtests/1.json
  def show
  end

  # GET /certtests/new
  def new
    @certtest = Certtest.new
  end

  # GET /certtests/1/edit
  def edit
  end

  # POST /certtests
  # POST /certtests.json
  def create
    @certtest = Certtest.new(certtest_params)

    respond_to do |format|
      if @certtest.save
        format.html { redirect_to @certtest, notice: 'Certtest was successfully created.' }
        format.json { render :show, status: :created, location: @certtest }
      else
        format.html { render :new }
        format.json { render json: @certtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certtests/1
  # PATCH/PUT /certtests/1.json
  def update
    respond_to do |format|
      if @certtest.update(certtest_params)
        format.html { redirect_to @certtest, notice: 'Certtest was successfully updated.' }
        format.json { render :show, status: :ok, location: @certtest }
      else
        format.html { render :edit }
        format.json { render json: @certtest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certtests/1
  # DELETE /certtests/1.json
  def destroy
    @certtest.destroy
    respond_to do |format|
      format.html { redirect_to certtests_url, notice: 'Certtest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certtest
      @certtest = Certtest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def certtest_params
      params.require(:certtest).permit(:name, :description, :project_id)
    end
end
