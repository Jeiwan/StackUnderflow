module QuestionsHelper
  def is_active?(page)
    "active" if params[:action] == page.to_s
  end
end
