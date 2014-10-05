class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :user
end
