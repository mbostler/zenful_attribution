module ApplicationHelper
  PRECISION = 5

  def flash_display
    out = ""
    flash.each do |type, msg|
       out << flash_msg(type, msg).html_safe
    end

    out.html_safe
  end

  def flash_msg(type, msg)
    human_key = type.to_s.downcase

    return content_tag(:div, :class => "#{human_key} box") do
      content_tag(:h2, human_key.capitalize) +
      content_tag(:div, :class => "block") do
        msg
      end
    end
  end
  
  # turns a number into percent. Assumes 
  def percenticize( num )
    return "(nil)" if num.nil?
    perf2string num
  end
  
  def perf2string( num )
    proper_num_to_pretty_num num
  end

  def contrib2string( num )
    proper_num_to_pretty_num num
  end

  def proper_num_to_pretty_num( x )
    "% 0.#{PRECISION}f %" % (x.to_f*100)
  end
  alias_method :pp, :proper_num_to_pretty_num
  
end
