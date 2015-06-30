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

class AxysSystem::Company < ActiveRecord::Base
  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  has_many :holdings, class_name: "AxysSystem::Holding"
  has_many :transactions, class_name: "AxysSystem::Transaction"
  
  validates :cusip, uniqueness: true, unless: "cusip.blank?"
  
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
    return false if code and code =~ /legalfeepay/i
    return false if code and code =~ /redpay/i
    code and code =~ /pay$/i
  end
  
  def tag
    tag = ticker || code || symbol
  end
end
  
