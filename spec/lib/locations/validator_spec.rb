require 'csv'
require 'locations/validator'

RSpec.describe Locations::Validator do
  describe '.valid?' do
    [
      {
        description: 'with all valid values',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: true
      },
      {
        description: 'with empty mystery_value',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,-23.567731,-46.633924,",
        expected_validity: false
      },
      {
        description: 'with missing mystery_value',
        csv: "ip_address,country_code,country,city,latitude,longitude\n192.168.0.1,BR,Brasil,São Paulo,-23.567731,-46.633924",
        expected_validity: false
      },
      {
        description: 'with missing longitude',
        csv: "ip_address,country_code,country,city,latitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,-23.567731,3246415903554",
        expected_validity: false
      },
      {
        description: 'with invalid longitude',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,-23.567731,invalid,3246415903554",
        expected_validity: false
      },
      {
        description: 'with invalid latitude',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,invalid,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with missing latitude',
        csv: "ip_address,country_code,country,city,longitude,mystery_value\n192.168.0.1,BR,Brasil,São Paulo,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with empty city',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with missing city',
        csv: "ip_address,country_code,country,latitude,longitude,mystery_value\n192.168.0.1,BR,Brasil,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with empty country',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,BR,,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with missing country',
        csv: "ip_address,country_code,city,latitude,longitude,mystery_value\n192.168.0.1,BR,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with empty country code',
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\n192.168.0.1,,Brasil,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with missing country code',
        csv: "ip_address,country,city,latitude,longitude,mystery_value\n192.168.0.1,Brasil,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with invalid ip address' ,
        csv: "ip_address,country_code,country,city,latitude,longitude,mystery_value\ninvalid,BR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
      {
        description: 'with missing ip_address',
        csv: "country_code,country,city,latitude,longitude,mystery_value\nBR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554",
        expected_validity: false
      },
    ].each do |conditions|
      context conditions[:description] do
        it do
          row = CSV.parse(conditions[:csv], headers: true)[0]
          result = described_class.valid?(row)

          expect(result).to be conditions[:expected_validity]
        end
      end
    end
  end
end
