require 'rails_helper'

RSpec.describe User, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to ensure_length_of(:username).is_at_least(3).is_at_most(16) }
    it { is_expected.to allow_value("pedro", "Pedro123", "Pedro_Juan").for(:username) }
    it { is_expected.not_to allow_value("12", "$#!Pedro123", "Pedro Juan").for(:username) }
  end

  describe "associations" do
    it { is_expected.to have_many :questions }
    it { is_expected.to have_many :answers }
  end

end
