ThinkingSphinx::Index.define :question, with: :active_record, delta: true do
  #fields
  indexes title, sortable: true
  indexes body
  indexes user.username, as: :author, sortable: true

  #attributes
  has user_id, created_at, edited_at
end
