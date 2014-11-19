ThinkingSphinx::Index.define :question, with: :active_record, delta: true do
  #fields
  indexes title, sortable: true
  indexes body
  indexes user.username, as: :author, sortable: true

  #attributes
  has created_at, updated_at
  has votes_sum, type: :float
end
