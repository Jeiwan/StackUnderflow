require 'rails_helper'

describe ReputationChartService do
  let!(:user) { create(:user) }
  let!(:reputation1) { create(:reputation, value: 10, user: user) }
  let!(:reputation2) { create(:reputation, value: 20, user: user, created_at: 1.days.ago) }
  let!(:reputation3) { create(:reputation, value: 30, user: user, created_at: 3.days.ago) }

  today = Date.current
  result = [{percentage: 100.0, reputation: 30, date: today - 3.days}, {percentage: 0, reputation: 0, date: today - 2.days}, {percentage: 66.67, reputation: 20, date: today - 1.day}, {percentage: 33.33, reputation: 10, date: today}]

  describe "#chart" do
    it "returns the chart of reputations mapped to a specified period" do
      expect(ReputationChartService.new(user, 4).chart).to match_array result
    end
  end
end
