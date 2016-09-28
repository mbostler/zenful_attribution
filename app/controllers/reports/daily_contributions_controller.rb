class Reports::DailyContributionsController < ApplicationController
  before_action :set_reports_daily_contribution, only: [:show, :edit, :update, :destroy]

  # GET /reports/daily_contributions
  # GET /reports/daily_contributions.json
  def index
    @reports_daily_contributions = Reports::DailyContribution.all
  end

  # GET /reports/daily_contributions/1
  # GET /reports/daily_contributions/1.json
  def show
  end

  # GET /reports/daily_contributions/new
  def new
    @reports_daily_contribution = Reports::DailyContribution.new
  end

  # GET /reports/daily_contributions/1/edit
  def edit
  end

  # POST /reports/daily_contributions
  # POST /reports/daily_contributions.json
  def create
    @reports_daily_contribution = Reports::DailyContribution.new(reports_daily_contribution_params)

    respond_to do |format|
      if @reports_daily_contribution.save
        format.html { redirect_to @reports_daily_contribution, notice: 'Daily contribution was successfully created.' }
        format.json { render :show, status: :created, location: @reports_daily_contribution }
      else
        format.html { render :new }
        format.json { render json: @reports_daily_contribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/daily_contributions/1
  # PATCH/PUT /reports/daily_contributions/1.json
  def update
    respond_to do |format|
      if @reports_daily_contribution.update(reports_daily_contribution_params)
        format.html { redirect_to @reports_daily_contribution, notice: 'Daily contribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @reports_daily_contribution }
      else
        format.html { render :edit }
        format.json { render json: @reports_daily_contribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/daily_contributions/1
  # DELETE /reports/daily_contributions/1.json
  def destroy
    @reports_daily_contribution.destroy
    respond_to do |format|
      format.html { redirect_to reports_daily_contributions_url, notice: 'Daily contribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reports_daily_contribution
      @reports_daily_contribution = Reports::DailyContribution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reports_daily_contribution_params
      params[:reports_daily_contribution]
    end
end
