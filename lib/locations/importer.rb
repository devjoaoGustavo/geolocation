require 'csv'

module Locations
  class Importer
    attr_reader :validator, :persistence

    def initialize(validator: nil, persistence: nil)
      @validator = validator || Validator
      @persistence = persistence || IPLocation
    end

    def import_from_file(filename)
      records = []

      CSV.foreach(filename, headers: true) do |hash|
        next unless validator.call hash

        records << hash
      end

      persistence.upsert_all records
    end
  end
end
