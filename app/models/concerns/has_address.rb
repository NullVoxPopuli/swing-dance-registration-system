# frozen_string_literal: true

module HasAddress
  extend ActiveSupport::Concern

  # retrieve the address or an empty hash
  # so we don't need to check the existance of each address field
  def address
    metadata_safe['address'] || {}
  end

  def address_city=(city)
    metadata['address']['city'] = city
  end

  def city
    address['city']
  end

  def city=(name)
    self.metadata ||= {}
    self.metadata['address'] ||= {}
    self.metadata['address']['city'] = name
  end

  def state
    address['state']
  end

  def state=(name)
    self.metadata ||= {}
    self.metadata['address'] ||= {}
    self.metadata['address']['state'] = name
  end

  def zip
    address['zip']
  end

  def zip=(name)
    self.metadata ||= {}
    self.metadata['address'] ||= {}
    self.metadata['address']['zip'] = name
  end

  private

  def has_address
    errors.add('address', 'must have a city') unless address['city'].present?

    errors.add('address', 'must have a state') unless address['state'].present?

    # unless address["zip"].present?
    #   errors.add("address", "must have a zip code")
    # end
  end
end
