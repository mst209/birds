class CommonAncestorsController < ApplicationController
  def show
    render json: Node.compare(params[:node_id].to_i, params[:id].to_i)
  end
  private
  def request_params
    params.permit(:node_id, :id)
  end
end
