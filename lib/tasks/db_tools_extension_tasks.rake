require 'highline/import'

namespace :db do
  desc "Anonymize your database"
  task :anonymize => :environment do
    DbTools::Anonymizer.execute
  end
  
  namespace :user do
    desc "Change the password for an existing user"
    task :password => :environment do
      Spree::Setup.change_password
    end
  end
end

namespace :ssl do
  desc "Disallow SSL"
  task :disallow => :environment do
    set_allow_ssl(false)
  end
  
  desc "Allow SSL"
  task :allow => :environment do
    set_allow_ssl(true)
  end
  
  def set_allow_ssl(allow_ssl)
    if allow_ssl
      say "SSL allowed"
    else
      say "SSL disallowed"
    end
    Spree::Config.set(:allow_ssl_in_production => allow_ssl)
    Spree::Config.set(:allow_ssl_in_development_and_test => allow_ssl)
    if !allow_ssl && 'production' == RAILS_ENV.downcase
      say "\nWARNING: SSL is disallowed in production, this is not recommended\n\n"
    end  
  end
end

desc "Make the current database ready for use in a non-production environment, normally used after importing a copy of the production database into a test database."
task :deprod do
  Rake::Task["db:anonymize"].invoke
  Rake::Task["ssl:disallow"].invoke
  say "Any existing admin passwords have been reset, so you'll probably want to
    set a new password for an admin user.  Enter an admin user e-mail when prompted."
  Rake::Task["db:user:password"].invoke
  say "Deprod complete"
end

