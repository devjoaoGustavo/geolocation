# frozen_string_literal: true

require 'locations/importer'

RSpec.describe Locations::Importer do
  let(:out) { StringIO.new }

  before do
    $stdout = out
  end

  describe '.import_from_csv_file' do
    let(:validator) { double }
    let(:persistence) { double }

    before do
      allow(validator).to receive(:valid?).and_return(true)
      allow(persistence).to receive(:insert_all).and_return(true)
    end

    context 'with an existing file' do
      let(:filename) { 'spec/lib/locations/fake_locations.csv' }

      it 'calls the data validator for each parsed record' do
        expect(validator).to receive(:valid?).exactly(5).times

        described_class.new(validator:, persistence:).import_from_csv_file(filename)
      end

      it 'calls the persistence layer with parsed' do
        expect(persistence).to receive(:insert_all).once

        described_class.new(validator:, persistence:).import_from_csv_file(filename)
      end
    end

    describe 'statistics' do
      [
        {
           description: 'print time elapsed',
           matching: /Time Elapsed: [0-9]+.?[0-9]+(e-?\d{1,2})? seconds/
        },
        {
           description: 'print validation time',
           matching: /Validation: [0-9]+.?[0-9]+(e-?\d{1,2})? seconds/
        },
        {
           description: 'print persistence time',
           matching: /Persistence: [0-9]+.?[0-9]+(e-?\d{1,2})? seconds/
        },
        {
           description: 'print records processed',
           matching: /Records processed: 6/
        },
        {
           description: 'print accepted records',
           matching: /Accepted: 5/
        },
        {
           description: 'print discarted records',
           matching: /Discarted: 1/
        }
      ].each do |conditions|
        it conditions[:description] do
          described_class
            .new(validator:, persistence:)
            .import_from_csv_file('spec/lib/locations/fake_locations.csv')

          out.seek 0

          expect(out.read).to match conditions[:matching]
        end
      end
    end

    context 'with non existing file' do
      let(:filename) { 'doesnotexist.csv' }

      it 'raises an error' do
        expect do
          described_class.new(validator:, persistence:).import_from_csv_file(filename)
        end.to raise_error(Errno::ENOENT)
      end
    end
  end
end
