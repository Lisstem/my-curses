class FormattedString
	attr_reader :string, :color
	def initialize(string, color = nil)
		@string = string
		@color = color
	end

	def to_s
		return "<@string=\"#{string}\", @color=#{color}>"
	end
end
