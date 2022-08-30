require 'csv'
require 'benchmark'

module Locations
  class Importer
    PERSISTENCE_BATCH_SIZE = 200_000
    private_constant :PERSISTENCE_BATCH_SIZE

    attr_reader :validator, :persistence

    ##
    # @param validator [Class]
    # @param persistence [Class]
    def initialize(validator: nil, persistence:)
      @validator = validator || Validator
      @persistence = persistence
    end

    ##
    # @param filename [String]
    def import_from_csv_file(filename)
      discarted = 0
      records = {}
      seen = {}

      Rails.logger.info 'starting...'
      time = Benchmark.realtime {
        validation = Benchmark.realtime {
          CSV.foreach(filename, headers: true) do |row|
            ip_address = row['ip_address']
            next discarted += 1 if seen[ip_address]

            seen[ip_address] = true
            next discarted += 1 unless validator.valid?(row)

            records[ip_address] = row.to_h
          end
        }
        Rails.logger.info "#{validation} seconds to validate"
        persistence_time = Benchmark.realtime {
          persist(records.values)
        }
        Rails.logger.info "#{persistence_time} seconds to persist"
      }

      Rails.logger.info "Time Elapsed: #{time} seconds."
      Rails.logger.info "Records accepted: #{records.count}."
      Rails.logger.info "Records discarted: #{discarted}."
    end

    def persist(records)
      records.each_slice(PERSISTENCE_BATCH_SIZE) do |batch|
        persistence.insert_all batch, returning: false
      end
    end
  end
end
