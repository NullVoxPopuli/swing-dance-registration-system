class Api::PackagesController < Api::EventResourceController
  private

  def update_package_params
    params
      .require(:data)
      .require(:attributes)
      .permit(
        :name,
        :initial_price, :at_the_door_price,
        :attendee_limit, :expires_at, :requires_track,
        :ignore_pricing_tiers, :deleted_at
      )
  end

  # @example
  #   {"data"=>{
  #      "attributes"=>{
  #         "number_of_leads"=>nil, "number_of_follows"=>nil, "name"=>"", "requirement"=>2},
  #      "relationships"=>{"event"=>{"data"=>{"type"=>"events", "id"=>"16"}}},
  #    "type"=>"levels"}, "level"=>{}}
  def create_package_params
    attributes = params
      .require(:data)
      .require(:attributes)
      .permit(:name, :initial_price, :at_the_door_price,
      )

    event_relationship = params
      .require(:data).require(:relationships)
      .require(:event).require(:data).permit(:id)

    attributes.merge(event_id: event_relationship[:id])
  end

end
