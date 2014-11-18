ThinkingSphinx::Index.define :answer, with: :active_record, delta: true do
  #fields
  indexes body
  indexes user.username, as: :author, sortable: true

  #attributes
  has user_id, created_at, edited_at
end
