require 'locations/importer'

RSpec.describe Locations::Importer do
  describe '.import_from_file' do
    let(:validator) { double }
    let(:persistence) { double }

    before do
      allow(validator).to receive(:call).and_return(true)
      allow(persistence).to receive(:upsert_all).and_return(true)
    end

    context 'with an existing file' do
      let(:filename) { 'spec/lib/locations/fake_locations.csv' }

      it 'calls the data validator for each parsed record' do
        expect(validator).to receive(:call).exactly(6).times

        described_class.new(validator: validator, persistence: persistence).import_from_file(filename)
      end

      it 'calls the persistence layer with parsed' do
        expect(persistence).to receive(:upsert_all).once

        described_class.new(validator: validator, persistence: persistence).import_from_file(filename)
      end
    end

    context 'with non existant file' do
      let(:filename) { 'doesnotexist.csv' }

      it 'raises an error' do
        expect do
          described_class.new(validator: validator, persistence: persistence).import_from_file(filename)
        end.to raise_error(Errno::ENOENT)
      end
    end
  end
end
