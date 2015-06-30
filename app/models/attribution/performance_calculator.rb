class Attribution::PerformanceCalculator
  def self.calc( opts={} )
    bmv_value = opts[:bmv_value]
    emv_value = opts[:emv_value]
    txns_value = opts[:txns_value]
    
    if bmv_value.zero?
      emv_value / txns_value
    else
      (emv_value - txns_value) / bmv_value
    end
  end
end
