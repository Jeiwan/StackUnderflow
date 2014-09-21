require 'rails_helper'

RSpec.describe Comment, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }
  end

  describe "associations" do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :commentable }
  end

end
