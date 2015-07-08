class HousingRequest < ActiveRecord::Base
  include CSVOutput

  # Store the list of requested and unwanted
  # roommates as a list of strings
  serialize :requested_roommates, JSON
  serialize :unwanted_roommates, JSON


  belongs_to :host, polymorphic: true
  belongs_to :attendance, -> { with_deleted }, polymorphic: true

  belongs_to :event, class_name: Event.name,
    foreign_key: 'host_id', foreign_type: 'host_type', polymorphic: true

  # TODO: Implement #177
  belongs_to :housing_provision

  # alias so that we can use proper english
  alias_attribute :needs_transportation, :need_transportation

  #
  def requested_roommate_names
    requested_roommates || []
  end

  def unwanted_roommate_names
    unwanted_roommates || []
  end

  def requested_roommate_name_list
    requested_roommate_names.keep_if{|n| n.present?}.join(", ")
  end

  def unwanted_roommate_name_list
    unwanted_roommate_names.keep_if{|n| n.present?}.join(", ")
  end


end