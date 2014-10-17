require 'rails_helper'

RSpec.describe Impression, :type => :model do

  it { is_expected.to belong_to :question }
  it { is_expected.to belong_to :user }

  it { is_expected.to validate_presence_of :remote_ip }
  it { is_expected.to validate_presence_of :user_agent }

end
