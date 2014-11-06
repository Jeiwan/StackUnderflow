class TagsController < ApplicationController
  authorize_resource

  def index
    @tags = Tag.page(params[:page])
  end

  def popular
    @tags = Tag.popular.page(params[:page])
    render :index
  end

  def newest
    @tags = Tag.newest.page(params[:page])
    render :index
  end
end
