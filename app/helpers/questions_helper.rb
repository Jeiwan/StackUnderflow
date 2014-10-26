module QuestionsHelper
  def is_active?(page)
    "active" if current_scopes.keys.include?(page)
  end
end
