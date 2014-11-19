ThinkingSphinx::Index.define :answer, with: :active_record, delta: true do
  #fields
  indexes body
  indexes user.username, as: :author, sortable: true

  #attributes
  has created_at
  has votes_sum, type: :float
end
