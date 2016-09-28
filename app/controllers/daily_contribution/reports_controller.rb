class DailyContribution::ReportsController < ApplicationController
  before_action :set_daily_contribution_report, only: [:show, :edit, :update, :destroy]

  # GET /daily_contribution/reports
  # GET /daily_contribution/reports.json
  def index
    @daily_contribution_reports = DailyContribution::Report.all
  end

  # GET /daily_contribution/reports/1
  # GET /daily_contribution/reports/1.json
  def show
  end

  # GET /daily_contribution/reports/new
  def new
    @daily_contribution_report = DailyContribution::Report.new
  end

  # GET /daily_contribution/reports/1/edit
  def edit
  end

  # POST /daily_contribution/reports
  # POST /daily_contribution/reports.json
  def create
    @daily_contribution_report = DailyContribution::Report.new(daily_contribution_report_params)

    respond_to do |format|
      if @daily_contribution_report.save
        format.html { redirect_to @daily_contribution_report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @daily_contribution_report }
      else
        format.html { render :new }
        format.json { render json: @daily_contribution_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_contribution/reports/1
  # PATCH/PUT /daily_contribution/reports/1.json
  def update
    respond_to do |format|
      if @daily_contribution_report.update(daily_contribution_report_params)
        format.html { redirect_to @daily_contribution_report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_contribution_report }
      else
        format.html { render :edit }
        format.json { render json: @daily_contribution_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_contribution/reports/1
  # DELETE /daily_contribution/reports/1.json
  def destroy
    @daily_contribution_report.destroy
    respond_to do |format|
      format.html { redirect_to daily_contribution_reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_contribution_report
      @daily_contribution_report = DailyContribution::Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_contribution_report_params
      params[:daily_contribution_report]
    end
end
