namespace :data do
  task import_from_csv_file: :environment do |_task, args|
    filename = args[:filename].presence || Rails.root.join('public/data_dump.csv')

    $stdout.puts "[Rake task] importing data from #{filename}..."

    time = Benchmark.realtime {
      importer = Locations::Importer.new(
        validator: Locations::Validator,
        persistence: IpLocation
      )

      importer.import_from_csv_file(filename)
    }
    $stdout.puts "[Rake task] completed in #{time} seconds"
  end
end
