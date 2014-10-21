class TagsController < ApplicationController
  def index
    @tags = Tag.popular
  end

  def alphabetical
    @tags = Tag.alphabetical
    render "index"
  end

  def newest
    @tags = Tag.newest
    render "index"
  end
end
