namespace :data do
  task import: :environment do
    puts ApplicationRecord.name
  end
end
