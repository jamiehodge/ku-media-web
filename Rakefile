require 'queue_classic/tasks'

namespace :qc do

  desc 'Environment'
  task :environment do
    require_relative 'config/queue_classic'
  end
end

namespace :db do
  
  desc 'Environment'
  task :environment do
    require 'sequel'
    DB = Sequel.connect ENV['DATABASE_URL']
  end
  
  desc 'Seed database'
  task seed: :environment do
    DB.extension :pg_hstore
    require_relative 'db/seed'
  end
  
  namespace :migrate do
    
    desc 'Environment'
    task environment: :'db:environment' do
      Sequel.extension :migration, :constraint_validations, :pg_hstore
    end
    
    desc 'Automigrate database'
    task auto: :environment do
      Sequel::Migrator.run DB, 'db/migrate', target: 0
      Sequel::Migrator.run DB, 'db/migrate'
    end
    
    desc 'Migrate to'
    task :to, [:target] => :environment do |t, args|
      Sequel::Migrator.run DB, 'db/migrate', target: args[:target]
    end
    
    desc 'Migrate up'
    task up: :environment do
      Sequel::Migrator.run DB, 'db/migrate'
    end
    
    desc 'Migrate down'
    task down: :environment do
      Sequel::Migrator.run DB, 'db/migrate', target: 0
    end
  end
  
  task migrate: 'migrate:up'
  
  namespace :test do
    task prepare: :environment do
      Rake::Task['db:seed'].invoke
    end
  end
end
