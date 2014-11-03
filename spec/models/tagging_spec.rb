require 'rails_helper'

RSpec.describe Tagging, :type => :model do

  it { is_expected.to belong_to :question }
  it { is_expected.to belong_to :tag }

end
