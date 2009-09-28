# Db Tools #
An extension to add a few useful Spree-related database rake tasks.

## Rake Tasks ##

### rake deprod ###
A combination of the below rake tasks that uses an already-imported copy of a 
production database and makes it ready for use in a non-production environment.

Specifically this task does the following:

*   Anonymizes the database (preserves admin emails)
*   Disallows SSL so the app can be used without SSL
*   Prompts you to enter an existing admin email address and a new password for that user.  This is provided as the password would have been reset by the anonymization process.

I use 'rake deprod' when I want a production-like database in a testing environment.
Remember you'll have to export and import your production database yourself before
calling this task.

### rake db:anonymize ###
This will not run if the RAILS_ENV is production.

Anonymize the Spree-core tables. I've included anonymization for as much
sensitive data as I could find in the Spree-core tables, I may have missed some
sensitive data, so please check that all the data you want is anonymized
and let me know if anything is missing.

Before running this task I recommend you take a look at the
DbTools::Anonymizer class to see what this method does in case it is too heavy
handed for your needs.

You can add your own anonymization steps by overriding the 
DbTools::Anonymizer.anonymize_custom method.

This task does not change the admin e-mail addresses, it does reset the admin
passwords.  Use rake db:user:password (see below) to change an admin password.

### rake ssl:allow ###
Allow SSL (sets preferences :allow_ssl_in_production and
:allow_ssl_in_development_and_test to true)

### rake ssl:disallow ###
Disallow SSL (sets preferences :allow_ssl_in_production and
:allow_ssl_in_development_and_test to false)

### rake db:user:password ###
Change the password for an existing user (prompts for e-mail and new password)

### rake db:sample and rake db:bootstrap ###
Overrides the existing sample data loading for spree so sample data specified in
extensions is loaded after loading the spree-core sample data.

## Installation ##
You'll be prompted to install the sevenwire-forgery gem. You can do this by
calling: rake gems:install

Contributions and feedback welcome,

Eliot Sykes

[http://github.com/eliotsykes/spree-db-tools](http://github.com/eliotsykes/spree-db-tools)   
[http://blog.eliotsykes.com/](http://blog.eliotsykes.com/)

