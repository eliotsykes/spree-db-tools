class DbToolsExtension < Spree::Extension
  version "1.0"
  description "An extension to add a few useful database related rake tasks."
  url "http://github.com/eliotsykes/spree-db-tools"
  
  def self.require_gems(config)
    config.gem "sevenwire-forgery", :lib => "forgery", :source => "http://gems.github.com"
  end
  
  def activate
    
    Spree::Setup.class_eval do
      def self.change_password
        new.change_password
      end
      
      def change_password
        say "Change password for a user (press enter for defaults)."
        email = ask("User's email [spree@example.com]: ", String) do |q|
          q.echo = true
          q.validate = proc do |email|
            email = 'spree@example.com' if email.blank?
            return User.exists?(:email => email)
          end
          q.responses[:not_valid] = "Invalid e-mail.  No user with this e-mail."
          q.whitespace = :strip
        end
        email = 'spree@example.com' if email.blank?
        user = User.find_by_login email
        say "Enter new password"
        password = prompt_for_admin_password
        user.update_attributes!(:password => password, :password_confirmation => password)
        say "Password updated for user '#{user.email}'"
      end
      
      def self.method_added(method_name)
        # Resorted to this as the original Spree::Setup.load_sample_data is always
        # loaded by rake.  When the original load_sample_data method is added to the
        # class, it is aliased so the replacement method is used.
        if (method_name == :load_sample_data && !@load_sample_data_aliased)
          @load_sample_data_aliased = true
          Spree::Setup.alias_method_chain :load_sample_data, :extensions
        end
      end
      
      # Uses a special set of fixtures to load sample data from spree root and extensions
      def load_sample_data_with_extensions
        # load initial database fixtures (in db/sample/*.yml) into the current environment's database
        ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
        
        # sample data can be loaded from Spree root and extensions.
        sample_data_roots = [SPREE_ROOT] + Spree::ExtensionLoader.instance.load_extension_roots
        
        sample_data_roots.each do |sample_data_root|
          Dir.glob(File.join(sample_data_root, "db", 'sample', '*.{yml,csv}')).each do |fixture_file|
            Fixtures.create_fixtures("#{sample_data_root}/db/sample", File.basename(fixture_file, '.*'))
          end
        end
  
        # make product images available to the app
        target = "#{RAILS_ROOT}/public/assets/products/"
        sample_data_roots.each do |sample_data_root|
          source = "#{sample_data_root}/lib/tasks/sample/products/"
          if File.exists?(source)
            Find.find(source) do |f|
              # omit hidden directories (SVN, etc.)
              if File.basename(f) =~ /^[.]/
                Find.prune 
                next
              end
      
              src_path = source + f.sub(source, '')
              target_path = target + f.sub(source, '')
      
              if File.directory?(f)
                FileUtils.mkdir_p target_path
              else
                FileUtils.cp src_path, target_path
              end
            end
          end
        end
        
        # HACK - need to add all sample users to the 'user' role (can't do this in sample fixtures because user role is seed data)
        user_role = Role.find_by_name "user"
        if user_role
          User.all.each { |u| u.roles << user_role unless u.has_role?("user") } 
        end
  
        announce "Sample data has been loaded"
      end
      
    end
    
  end
end
