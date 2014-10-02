class TagListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.nil?
      record.errors[attribute] << "must include at least one tag."
    else
      value.split(" ").each do |tag|
        unless tag =~ /\A[a-zA-Z][\w#\+\-\.]*\z/
          record.errors[attribute] << "Every tag must begin with a letter and contain only: letters, digits, ., +, -, _, and #. Tags must be separated by a space."
        end
      end
    end
  end
end
