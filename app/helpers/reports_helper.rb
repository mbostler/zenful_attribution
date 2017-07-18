module ReportsHelper
  def results_by_tag( report )
    results_for_report( report ).sort_by { |r| r[:tag] }
  end
  
  def results_by_performance( report )
    results_for_report( report ).sort_by { |r| r[:performance] }.reverse
  end
  
  def results_by_contribution( report )
    results_for_report( report ).sort_by { |r| r[:contribution] }.reverse
  end
  
  def results_by_efficiency( report )
    results_for_report( report ).sort_by { |r| r[:performance_efficiency] }.reverse
  end
  
  def results_for_report( report )
    report.results.keys.map do |tag|
      { 
        tag: tag, 
        performance: report.results[tag][:performance],
        contribution: report.results[tag][:contribution],
        days_held: report.days_by_holding[tag].size,
        performance_efficiency: (report.results[tag][:performance]-1) / report.days_by_holding[tag].size
      }
    end    
  end
  
  def print_table( results )
    html = "<table>"
    html << "<thead>
	      <tr>
			  <th>Ticker</th>
			  <th>Return</th>
			  <th>Contribution</th>
			  <th>Holding period (days)</th>
			  <th>Efficiency (Return / days)</th>
	      </tr>
	    </thead>
  	  <tbody>"
      results.each do |result|
        html << "<tr>
  			  <td>#{result[:tag]}</td>
  		  	<td>#{percenticize result[:performance] - 1}</td>
  		  	<td>#{percenticize result[:contribution]}</td>
  		  	<td>#{result[:days_held]}</td>
  		  	<td>#{percenticize result[:performance_efficiency]}</td>
  		  </tr>"
  		end
      html << "</tbody>"
      html << "</table>"
  	  
      html.html_safe
  end

end
