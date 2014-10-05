class Attachment < ActiveRecord::Base
  belongs_to :question
  mount_uploader :file, FileUploader
end
