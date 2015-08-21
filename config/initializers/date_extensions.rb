class Date
	def trading_day?
		return false unless (1..5).cover? self.wday
		return false if Holiday.on? self
		true
	end
  
  def reportable_day?
    return true if last_day_of_month?
    trading_day?
  end

  def last_day_of_month?
    month != (self+1).month
  end
	
	def previous_reportable_day
	  day = self.clone - 1.day
	  day -= 1.day until day.reportable_day?
	  day
	end
	alias_method :prev_reportable_day, :previous_reportable_day

	def previous_trading_day
	  day = self.clone - 1.day
	  day -= 1.day until day.trading_day?
	  day
	end
	alias_method :prev_trading_day, :previous_trading_day

	def next_trading_day
	  day = self.clone + 1.day
	  day += 1.day until day.trading_day?
	  day
	end

end