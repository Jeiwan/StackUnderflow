ThinkingSphinx::Index.define :user, with: :active_record, delta: true do
  #fields
  indexes username
  indexes location
  indexes website
  indexes full_name

  #attributes
  has created_at, reputation_sum
end
