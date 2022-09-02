require 'csv'
require 'locations/validator'

RSpec.describe Locations::Validator do
  describe '.valid?' do
    [
      {
        description: 'with all valid values',
        row: "192.168.0.1,BR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: true
      },
      {
        description: 'with empty mystery_value',
        row: "192.168.0.1,BR,Brasil,São Paulo,-23.567731,-46.633924,".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with missing longitude',
        row: "192.168.0.1,BR,Brasil,São Paulo,-23.567731,,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with invalid longitude',
        row: "192.168.0.1,BR,Brasil,São Paulo,-23.567731,invalid,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with invalid latitude',
        row: "192.168.0.1,BR,Brasil,São Paulo,invalid,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with missing latitude',
        row: "192.168.0.1,BR,Brasil,São Paulo,,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with empty city',
        row: "192.168.0.1,BR,Brasil,,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with empty country',
        row: "192.168.0.1,BR,,São Paulo,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with empty country code',
        row: "192.168.0.1,,Brasil,São Paulo,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with invalid ip address' ,
        row: "invalid,BR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with lessa fields than expected',
        row: "192.168.0.1,BR,Brasil,São Paulo,-46.633924".split(',', 7),
        expected_validity: false
      },
      {
        description: 'with empty ip_address',
        row: ",BR,Brasil,São Paulo,-23.567731,-46.633924,3246415903554".split(',', 7),
        expected_validity: false
      },
    ].each do |conditions|
      context conditions[:description] do
        it do
          result = described_class.valid?(*conditions[:row])

          expect(result).to be conditions[:expected_validity]
        end
      end
    end
  end
end
