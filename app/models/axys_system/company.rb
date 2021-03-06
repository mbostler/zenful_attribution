# == Schema Information
#
# Table name: axys_system_companies
#
#  id         :integer          not null, primary key
#  cusip      :string
#  ticker     :string
#  code       :string
#  name       :string
#  security   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  symbol     :string
#

class AxysSystem::Company < ApplicationRecord
  # belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  has_many :holdings, class_name: "AxysSystem::Holding"
  has_many :transactions, class_name: "AxysSystem::Transaction"
  
  validates :cusip, uniqueness: true, unless: Proc.new { |c| c.cusip.blank? }
  
  def self.find_or_create_from_attribs!( attribs )
    [:cusip, :code, :symbol].each do |unique_sym|
      if attribs[unique_sym].present?
        found_co = where( unique_sym => attribs[unique_sym] ).first
        return found_co if !!found_co
        new_co = create!( attribs )
        return new_co if !!new_co
      end
    end
    
    raise "couldn't create company! needed to see either :cusip or :code, but was given #{attribs.inspect}"
  end
  
  def excluded?
    # THE FOLLOWING IS USED TO IGNORE +&smcomp MUTUAL FUND SELL ON 2/2/2010
    return true if (ticker || code || symbol).nil?

    # return false if code and code =~ /legalfeepay/i
    # return false if code and code =~ /redpay/i
    # code and code =~ /pay$/i
    forbidden_tags = %w(
      legalfeepay intacc admin ticket cust acct manfeepay custfeepay
      acctfeepay adminfeepay redpay ticketfeepay legalfee manfee
                        )
    return true if cusip == "FFALX" && ticker.nil? && symbol.nil?
    return true if forbidden_tags.any?{ |t| tag.upcase == t.upcase }
    

    # NOTE: THE BELOW 2 LINES WORK PERFECTLY FOR 
    # - MARYLAND 4/30/2017 - 5/19/2017
    # return true if code and code =~ /legalfeepay/i
    # return true if tag =~ /manfee/i

    false
  end
  
  def tag
    t = (ticker || code || symbol || "(No tag found)") 
    if t.nil?
      raise "could not find tag for company: #{self.inspect}"
    end
    t.upcase
  end
end
  
