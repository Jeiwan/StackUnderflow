class ReputationChartService
  def initialize(user, days)
    @user = user
    @period = days
  end

  def chart
    @reputations ||= map_to_period(prepare_array(get_reputations))
  end

  private

    def get_reputations
      @user.reputations.select("cast(created_at as date)", "sum(value) as value").where("created_at >= ?", @period.days.ago).group("cast(created_at as date)").order("sum(value) DESC")
    end

    def prepare_array(relations)
      unless relations.blank?
        max = relations[0].value
        relations.map { |r| {percentage: ((r.value / max.to_f * 100).round(2)), reputation: r.value, date: r.created_at} }
      end
    end

    def map_to_period(array)
      unless array.blank?
        ((@period-1).days.ago.to_date..Date.current).map do |date|
          reputation = array.select { |r| r[:date] == date }
          reputation[0] ? reputation[0] : {date: date, reputation: 0, percentage: 0}
        end
      end
    end
end
