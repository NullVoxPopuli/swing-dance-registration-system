class EventAttendance < Attendance
	include ::EventItemHelpers
	include AttendanceDownloadableData

	belongs_to :event, class_name: Event.name,
	 foreign_key: "host_id", foreign_type: "host_type", polymorphic: true

	belongs_to :level
	belongs_to :package
	belongs_to :pricing_tier

	# for an attendance, we don't care if any of our
	# references are deleted, we want to know what they were
	def package; Package.unscoped{ super }; end
	def level; Level.unscoped{ super }; end
	def event; Event.unscoped{ super }; end

	has_and_belongs_to_many :competitions,
	join_table: "attendances_competitions",
	association_foreign_key: "competition_id", foreign_key: "attendance_id"

	has_and_belongs_to_many :discounts,
	join_table: "attendances_discounts",
	association_foreign_key: "discount_id", foreign_key: "attendance_id"


	scope :with_competitions, ->{
	joins(:competitions).group("attendances.id")
}

scope :with_packages, ->{
joins(:package).group("attendances.id")
}
scope :with_package, ->(package_id) {
where("package_id = #{package_id}")
}

scope :with_level, ->(level_id){
where(level_id: level_id)
}

scope :with_a_la_cart, ->{
joins(:a_la_cart).group("attendances.id")
}

scope :needing_housing, ->{ where(needs_housing: true) }
scope :providing_housing, ->{ where(providing_housing: true) }
scope :volunteers, ->{ where(interested_in_volunteering: true) }

validates :pricing_tier, presence: true
validates :event, presence: true
# validates :attendee, presence: true
validates :package, presence: true
validates :dance_orientation, presence: true
validates :level, presence: true, if: Proc.new {|a| (p = a.package) && p.requires_track? }
validate :has_address, if: Proc.new {|a| !(a.event.present? && event.started?)}
validate :has_phone_number, if: Proc.new { |a| a.interested_in_volunteering? }
validate :has_name, if: Proc.new { |a| a.attendee_id.blank? && a.attendee.blank? }

def crossover_orientation=(o)
	self.metadata["crossover_orientation"] = o
end

def crossover_orientation
	self.metadata["crossover_orientation"]
end


def requested_housing_data
	metadata_safe["need_housing"]
end

def providing_housing_data
	metadata_safe["providing_housing"]
end

private

def has_phone_number
	unless metadata_safe['phone_number'].present?
		errors.add('phone number', 'must be present when volunteering')
	end
end

def has_name
	unless metadata_safe['first_name'].present?
		errors.add('first name', 'must be present')
	end
	unless metadata_safe['last_name'].present?
		errors.add('last name', 'must be present')
	end
end

# if an attendance doesn't have an order, calculate things at
# the current prices
def total_cost
	total = 0
	total += package.current_price if package
	competitions.each{ |c| total += c.current_price }
	line_items.each{ |l| total += l.current_price }
	shirts.each{ |l| total += l.current_price }
	discounts.each{ |d|
		if d.kind == Discount::DOLLARS_OFF
			total -= d.value
		elsif d.kind == Discount::PERCENT_OFF
			total *= (1 - d.value / 100.0)
		end
	}
	return total
end

end