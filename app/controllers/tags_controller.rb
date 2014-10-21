class TagsController < ApplicationController
  def index
    @tags = Tag.popular
  end
end
