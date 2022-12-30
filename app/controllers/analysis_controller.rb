class AnalysisController < ApplicationController
  before_action :validate_params

  def index
    duration  = params[:duration]
    dimension = params[:dimension]

    statistics = Analyze.call(duration, dimension)

    render json: statistics
  end

  private

  def validate_params
    duration_regex  = /^\d+([smh])$/
    dimension_regex = /^(likes|comments|favorites|retweets)$/

    unless params[:duration].match?(duration_regex)
      render json: { 'error' => 'invalid_duration_parameter' }, status: :bad_request

      return
    end

    unless params[:dimension].match?(dimension_regex)
      render json: { 'error' => 'invalid_dimension_parameter' }, status: :bad_request

      return
    end
  end
end
