# object is actually an Event
class HostedEventSerializer < ActiveModel::Serializer

  attributes :id, :name, :location,
    :registration_opens_at, :starts_at, :ends_at, :url,
    :number_of_leads, :number_of_follows, :number_of_shirts_sold


    def number_of_leads
      object.attendances.leads.count
    end

    def number_of_follows
      object.attendances.follows.count
    end

    def number_of_shirts_sold
      object.shirts_sold
    end
end
