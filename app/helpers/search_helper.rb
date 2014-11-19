module SearchHelper
  def search_params
    available_params = [:q, :target]
    actual_params = {}

    available_params.each { |param| actual_params[param] = params[param] unless params[param].blank? }
    actual_params
  end

  def sort_active?(sort, default=false)
    params[:order] == sort.to_s ? 'active' : ''
  end
end
