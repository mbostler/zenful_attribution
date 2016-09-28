class Spreadsheet::Worksheet
  attr_accessor :row_offset, :col_offset

  def row_offset
    @row_offset ||= 0
  end
  
  def col_offset
    @col_offset ||= 0
  end
  
  def from( row_offset, col_offset, &block )
    self.row_offset = row_offset
    self.col_offset = col_offset
    begin
      block.call self
    ensure
      self.row_offset = 0
      self.col_offset = 0
    end
  end
  
	def <<( data )
		idx = row_count.zero? ? 0 : last_row_index + 1

		if self.col_offset > 0
		  data.each_with_index do |val, i|
        self[self.row_offset, self.col_offset + i] = val
		  end
  		row( self.row_offset ).default_format = @row_format_override if @row_format_override
  		self.row_offset += 1
	  else
  		insert_row idx, data
  		last_row.default_format = @row_format_override if @row_format_override
  	end
	end
	alias_method :append_row, :<<

	def with_format( fmt, &block )
		@row_format_override = fmt
		block.call self
		@row_format_override = nil
	end

	def skip_row!
	  if self.row_offset > 0
	    self.row_offset += 1
    else
  		self << []
		end
	end
end

class GenericSpreadsheet
  include Enumerable
  
  def each
    first_row.upto(last_row).map do |i|
      row( i )
    end.each { |r| yield r }
  end
end