class ApplicationSerializer < ActiveModel::Serializer
  def files
    object.attachments.map { |a| {id: a.id, path: a.file.url, filename: a.file.file.filename} }
  end
end
