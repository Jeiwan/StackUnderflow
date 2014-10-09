require 'rails_helper'

RSpec.describe Vote, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :vote }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :votable_id }
    it { is_expected.to validate_presence_of :votable_type }
  end

  describe "associations" do
    it { is_expected.to belong_to :votable }
    it { is_expected.to belong_to :user }
  end

end
