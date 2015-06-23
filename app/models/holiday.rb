# == Schema Information
#
# Table name: holidays
#
#  id         :integer          not null, primary key
#  year       :integer
#  month      :integer
#  day        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Holiday < ActiveRecord::Base
	validates :day, :presence => true
	validates :month, :presence => true

	DATE_STRINGS = %w( 1995/9/4 1995/11/23 1995/12/25
              1996/1/1 1996/2/19 1996/4/5 1996/5/27
              1997/1/1 1997/2/14 1997/3/28 1997/5/27 1997/7/4 1997/9/1 1997/11/27 1997/12/25
              1998/1/1 1998/1/19 1998/2/16 1998/4/10 1998/5/25 1998/7/3 1998/9/7 1998/11/26 1998/12/25
              1999/1/1 1999/1/18 1999/2/15 1999/4/2 1999/5/31 1999/7/5 1999/9/6 1999/11/25 1999/12/24
              2000/1/1 2000/1/17 2000/2/21 2000/4/21 2000/5/29 2000/7/4 2000/9/4 2000/11/23 2000/12/25 
              2001/1/1 2001/1/15 2001/2/19 2001/4/13 2001/5/28 2001/7/4 2001/9/3 2001/9/11 2001/9/12 2001/9/13 2001/9/14 2001/11/22 2001/12/25
              2002/1/1 2002/1/21 2002/2/18 2002/3/29 2002/5/27 2002/7/4 2002/9/2 2002/11/28 2002/12/25
              2003/1/1 2003/1/20 2003/2/17 2003/4/18 2003/5/26 2003/7/4 2003/9/1 2003/11/27 2003/12/25
              2004/1/1 2004/1/19 2004/2/16 2004/4/9 2004/5/31 2004/6/14 2004/7/5 2004/9/6 2004/11/25 2004/12/24
              2005/1/1 2005/1/17 2005/2/21 2005/3/25 2005/5/30 2005/7/4 2005/9/5 2005/11/24 2005/12/26
              2006/1/2 2006/1/16 2006/2/20 2006/4/14 2006/5/29 2006/7/4 2006/9/4 2006/11/23 2006/12/25
              2007/1/1 2007/1/15 2007/2/19 2007/4/6 2007/5/28 2007/7/4 2007/9/3 2007/11/22 2007/12/25
              2008/1/1 2008/1/21 2008/2/18 2008/3/21 2008/5/26 2008/7/4 2008/9/1 2008/11/26 2008/12/25
              2009/1/1 2009/1/19 2009/2/16 2009/4/10 2009/5/25 2009/7/3 2009/9/7 2009/11/26 2009/12/25
	            2010/1/1 2010/1/18 2010/2/15 2010/4/2 2010/5/31 2010/7/5 2010/9/6 2010/11/25 2010/12/24
							2011/1/17 2011/2/21 2011/4/22 2011/5/30 2011/7/4 2011/9/5 2011/11/24 2011/12/26
							2012/1/2 2012/1/16 2012/2/20 2012/4/6 2012/5/28 2012/7/4 2012/9/3 2012/10/29 2012/10/30 2012/11/22 2012/12/25
							2013/1/1 2013/1/21 2013/2/18 2013/3/29 2013/5/27 2013/7/4 2013/9/2 2013/11/28 2013/12/25
							2014/1/1 2014/1/20 2014/2/17 2014/4/18 2014/5/26 2014/7/4 2014/9/1 2014/11/27 2014/12/25
							2015/1/1 2015/1/19 2015/2/16 2015/4/3 2015/5/25 2015/7/3 2015/9/7 2015/11/26 2015/12/25)	

	def self.on?( date )
    $holidays ||= Holiday.all
    holiday = $holidays.find { |h| h.year == date.year && h.month == date.month && h.day == date.day }
    !!holiday
	end

	def self.seed
		DATE_STRINGS.each { |datestring| add Date.parse( datestring ) }
	end

	def self.reseed!
		destroy_all
		seed
	end

	def self.add( date )
		holiday = where( :day => date.day, :month => date.month, :year => date.year )
		holiday.create! unless holiday.exists?
	end
end
