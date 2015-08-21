class Attribution::PerformanceCalculator
  def self.calc( opts={} )
    bmv_value = opts[:bmv_value]
    emv_value = opts[:emv_value]
    txns_value = opts[:txns_value]
    # puts "bmv_value is : " + bmv_value.inspect
    # puts "emv_value is : " + emv_value.inspect
    # puts "txns_value is : " + txns_value.inspect
    
    if [bmv_value, emv_value, txns_value].all?(&:zero?)
      1.0 # ie, zero percent return
    elsif bmv_value.zero?
      emv_value / txns_value
    else
      (emv_value - txns_value) / bmv_value
    end
  end
end
