class NestedResources::AnalysesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @analyses = @parent.analyses
    respond_with @analyses
  end

  def create
    @analysis = Analysis.new(analysis_params)
    @parent.analyses << @analysis
    respond_with @analysis, location: request.referer
  end

  def update
    @analysis = Analysis.find(params[:id])
    @parent.analyses << @analysis
    @parent.save
    respond_with @analysis
  end

  def destroy
    @analysis = Analysis.find(params[:id])
    @parent.analyses.delete(@analysis)
    respond_with @analysis, location: request.referer
  end

  private
  
  def analysis_params
    params.require(:analysis).permit(
      :name,
      :description,
      :stone_id,
      :technique_id,
      :device_id,
      :operator,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable,
        :published,
        :published_at
      ]
    )
  end

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

end
