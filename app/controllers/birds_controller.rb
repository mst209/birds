class BirdsController < ApplicationController
  def index
    render json: Node.search(node_ids)
  end

  private

  def request_params
    params.permit(:node_ids)
  end

  def node_ids
    request_params[:node_ids].split(',').map(&:to_i)
  end
end
