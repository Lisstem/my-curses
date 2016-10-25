class FormattedString
	attr_reader :string, :color
	def initialize(string, color = nil)
		@string = string
		@color = color
	end
end
