class TagsController < ApplicationController
  has_scope :popular, type: :boolean, allow_blank: true
  has_scope :alphabetical, type: :boolean, allow_blank: true
  has_scope :newest, type: :boolean, allow_blank: true

  def index
    @tags = apply_scopes(Tag).all
  end
end
