class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :avatar_url, :reputation, :tiny_avatar_url

  def avatar_url
    object.avatar.small.url
  end

  def tiny_avatar_url
    object.avatar.tiny.url
  end
end
