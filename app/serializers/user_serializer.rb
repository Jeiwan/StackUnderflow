class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :reputation, :small_avatar_url, :tiny_avatar_url

  def tiny_avatar_url
    object.avatar.tiny.url
  end
  
  def small_avatar_url
    object.avatar.small.url
  end

  def reputation
    object.reputation_sum
  end
end
