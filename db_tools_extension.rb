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
    end
    
  end
end
