require 'rails_helper'

RSpec.describe Tag, :type => :model do

  describe "associations" do
    it { is_expected.to have_and_belong_to_many :questions }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name  }
    it { is_expected.to ensure_length_of(:name).is_at_least(2).is_at_most(24)  }
  end
end
