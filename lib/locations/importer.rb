require 'csv'
require 'benchmark'

module Locations
  class Importer
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
      accepted = {}
      header = nil
      validation_time = 0
      persistence_time = 0

      $stdout.puts 'Importing data'
      total_time = Benchmark.realtime {
        $stdout.puts "validating... "
        validation_time = Benchmark.realtime {
          ##
          # ip_address, country_code, country, city, latitude, longitude, mystery_value
          CSV.foreach(filename) do |row|
            ip_address, _ = row
            next header = row if header?(ip_address)
            next discarted += 1 if accepted[ip_address]
            next discarted += 1 unless validator.valid?(*row)

            accepted[ip_address] = row
          end
        }
        $stdout.puts 'persisting... '
        persistence_time = Benchmark.realtime {
          persist(accepted.values.map { |values| header.zip(values).to_h })
          $stdout.puts "done."
        }
      }

      print_stats(total_time, validation_time, persistence_time, accepted.count, discarted)
    end

    private

    def header?(ip_address) = ip_address == 'ip_address'

    def persist(records) = persistence.insert_all(records)

    def print_stats(total_time, validation_time, persistence_time, accepted, discarted)
      $stdout.puts "==================================================="
      $stdout.puts "Time Elapsed: #{total_time.to_f} seconds"
      $stdout.puts "\tValidation: #{validation_time} seconds"
      $stdout.puts "\tPersistence: #{persistence_time} seconds"
      $stdout.puts "Records processed: #{accepted + discarted}"
      $stdout.puts "\tAccepted: #{accepted}"
      $stdout.puts "\tDiscarted: #{discarted}"
      $stdout.puts "==================================================="
    end
  end
end
