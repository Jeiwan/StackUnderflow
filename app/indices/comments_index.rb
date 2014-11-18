ThinkingSphinx::Index.define :comment, with: :active_record, delta: true do
  #fields
  indexes body
  indexes user.username, as: :author, sortable: true

  #attributes
  has user_id, created_at, updated_at
end
