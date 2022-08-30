require 'rails_helper'

RSpec.describe IpLocationSerializer do
  describe 'self.serialize_invalid_ip_address' do
    it 'renders error with 123' do
      result = described_class.serialize_invalid_ip_address(123)
      expect(result).to eq({
        error: {
          message: "`ip_address`: 123 is an invalid IP Address."
        }
      })
    end

    it 'renders error with nil' do
      result = described_class.serialize_invalid_ip_address(nil)
      expect(result).to eq({
        error: {
          message: "`ip_address`: nil is an invalid IP Address."
        }
      })
    end
  end

  describe 'self.serialize_ip_location_not_found' do
    it 'renders error with 192.168.0.2' do
      expect(described_class.serialize_ip_location_not_found('192.168.0.2')).to eq({
        error: {
          message: "No location found for `ip_address`: 192.168.0.2."
        }
      })
    end

    it 'renders error with empty string' do
      expect(described_class.serialize_ip_location_not_found('')).to eq({
        error: {
          message: "No location found for `ip_address`: nil."
        }
      })
    end
  end

  describe '#serialize' do
    let(:object) do
      IpLocation.create(ip_address: '192.168.0.1',
                        country_code: 'BR',
                        country: 'Brasil',
                        city: 'São Paulo',
                        latitude: -23.567731,
                        longitude: -46.633924,
                        mystery_value: 3246415903554)
    end

    it 'renders ip location based on given object' do
      result = described_class.new(object).serialize

      expect(result).to eq({
        ip_location: {
          ip_address: '192.168.0.1',
          city: 'São Paulo',
          country: 'Brasil',
          country_code: 'BR',
          latitude: -23.567731,
          longitude: -46.633924,
          mystery_value: 3246415903554
        }
      })
    end
  end
end
