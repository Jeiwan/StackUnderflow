class TagsController < ApplicationController
  def index
    @tags = Tag.all.order("name")
  end
end
