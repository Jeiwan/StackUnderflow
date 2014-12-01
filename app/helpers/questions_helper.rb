module QuestionsHelper
  def is_active?(page)
    "active" if params[:action] == page.to_s
  end

  def collection_key_for(model)
    klass = model.to_s.capitalize.constantize
    count = klass.count
    max_updated_at = klass.maximum(:updated_at).try(:utc).try(:to_i)
    "#{model.to_s.pluralize}/collection-#{count}-#{max_updated_at}"
  end
end
