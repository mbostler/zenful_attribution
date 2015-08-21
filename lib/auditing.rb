module Auditing
  PRECISION = 5

  def without_logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    result = yield
    ActiveRecord::Base.logger = old_logger
    result
  end

  def perf2string( num )
    proper_num_to_pretty_num num-1
  end

  def contrib2string( num )
    proper_num_to_pretty_num num
  end

  def proper_num_to_pretty_num( x )
    "% 0.#{PRECISION}f %" % (x.to_f*100)
  end
  alias_method :pp, :proper_num_to_pretty_num

end

