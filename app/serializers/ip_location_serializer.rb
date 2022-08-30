class IpLocationSerializer

  def self.serialize_invalid_ip_address(ip_address)
    {
      error: {
        message: "`ip_address`: #{ip_address.presence || 'nil'} is an invalid IP Address."
      }
    }
  end

  def self.serialize_ip_location_not_found(ip_address)
    {
      error: {
        message: "No location found for `ip_address`: #{ip_address.presence || 'nil'}."
      }
    }
  end

  attr_reader :object

  delegate :ip_address, :city, :country, :country_code, :mystery_value, to: :object

  def initialize(object)
    @object = object
  end

  def serialize
    {
      ip_location: {
        ip_address: ip_address,
        city: city,
        country: country,
        country_code: country_code,
        latitude: object.latitude.to_f,
        longitude: object.longitude.to_f,
        mystery_value: mystery_value
      }
    }
  end
end
