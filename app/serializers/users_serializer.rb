class UsersSerializer < ActiveModel::Serializer
  attributes :id, :username, :reputation, :medium_avatar_url, :location

  def medium_avatar_url
    object.avatar.medium.url
  end
  
  def reputation
    object.reputation_sum
  end
end
