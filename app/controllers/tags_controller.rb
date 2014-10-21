class TagsController < ApplicationController
  def index
    @tags = Tag.popular
  end

  def alphabetical
    @tags = Tag.alphabetical
    render "index"
  end
end
