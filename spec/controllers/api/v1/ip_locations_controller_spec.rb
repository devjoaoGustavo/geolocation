require 'rails_helper'

RSpec.describe Api::V1::IpLocationsController, type: :controller do
  describe 'GET search' do
    context 'when ip address is invalid' do
      let(:ip_address) { 123 }

      before { get 'search', params: { ip_address: ip_address } }

      it { expect(response).to have_http_status :unprocessable_entity }
      it { expect(response.body).to eq("{\"error\":{\"message\":\"`ip_address`: 123 is an invalid IP Address.\"}}") }
    end

    context 'when ip location is not found' do
      let(:ip_address) { '192.168.0.1' }

      before { get 'search', params: { ip_address: ip_address } }

      it { expect(response).to have_http_status :not_found }
      it { expect(response.body).to eq("{\"error\":{\"message\":\"No location found for `ip_address`: 192.168.0.1.\"}}") }
    end

    context 'when ip location is found' do
      let(:ip_address) { '192.168.0.1' }

      before do
        IpLocation.create(ip_address: '192.168.0.1',
                          country_code: 'BR',
                          country: 'Brasil',
                          city: 'São Paulo',
                          latitude: -23.567731,
                          longitude: -46.633924,
                          mystery_value: 3246415903554)

        get 'search', params: { ip_address: ip_address }
      end

      it { expect(response).to have_http_status :ok }

      it do
        expect(response.body).to eq({
          ip_location: {
            ip_address: '192.168.0.1',
            city: 'São Paulo',
            country: 'Brasil',
            country_code: 'BR',
            latitude: -23.567731,
            longitude: -46.633924,
            mystery_value: 3246415903554
          }
        }.to_json)
      end
    end
  end
end
