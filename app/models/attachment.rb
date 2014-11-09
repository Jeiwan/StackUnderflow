class Attachment < ActiveRecord::Base

  belongs_to :attachable, polymorphic: true
  belongs_to :user

  mount_uploader :file, FileUploader

  delegate :filename, to: :file
end
