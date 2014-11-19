ThinkingSphinx::Index.define :user, with: :active_record, delta: true do
  #fields
  indexes username, sortable: true
  indexes location, sortable: true
  indexes website
  indexes full_name, sortable: true

  #attributes
  has created_at
  has reputation_sum, type: :float
end
