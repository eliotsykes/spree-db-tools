module DbTools
  class Anonymizer
    # Anonymize sensitive information, if you find any sensitive data that is
    # not anonymized, please let me know and I'll add it.
    def self.execute
      assert_not_production
      anonymize_addresses
      anonymize_checkouts
      anonymize_creditcards
      anonymize_creditcard_txns
      anonymize_gateway_option_values
      anonymize_shipments
      anonymize_users
      anonymize_custom
    end
    
    private
    def self.ip_address
      return '127.0.0.1'
    end
    
    def self.assert_not_production
      raise "\nEXITING: Anonymizing production is not allowed" if 'production' == RAILS_ENV.downcase
    end
    
    def self.anonymize_addresses
      Address.all.each do |address|
        address.firstname = NameForgery.first_name if !address.firstname.blank?
        address.lastname = NameForgery.last_name if !address.lastname.blank?
        address.address1 = AddressForgery.street_address if !address.address1.blank?
        address.address2 = AddressForgery.street_name if !address.address2.blank?
        address.city = AddressForgery.city if !address.city.blank?
        address.zipcode = AddressForgery.zip if !address.zipcode.blank?
        address.phone = AddressForgery.phone if !address.phone.blank?
        address.alternative_phone = AddressForgery.phone if !address.alternative_phone.blank?
        address.save!
      end
      puts "Addresses anonymized"
    end
    
    def self.anonymize_checkouts
      Checkout.all.each do |checkout|
        edited = false
        if !checkout.email.blank?
          checkout.email = InternetForgery.email_address
          edited = true
        end
        if !checkout.ip_address.blank?
          checkout.ip_address = ip_address
          edited = true
        end
        checkout.save! if edited
      end
      puts "Checkouts anonymized"
    end
    
    def self.anonymize_creditcards
      Creditcard.all.each do |creditcard|
        creditcard.number = '1111-1111-1111-1111' if !creditcard.number.blank?
        creditcard.display_number = 'XXXX-XXXX-XXXX-1111' if !creditcard.display_number.blank?
        creditcard.month = 12  if !creditcard.month.blank?
        creditcard.year = 2011  if !creditcard.year.blank?
        creditcard.verification_value = '123' if !creditcard.verification_value.blank?
        creditcard.cc_type = 'visa' if !creditcard.cc_type.blank?
        creditcard.first_name = NameForgery.first_name if !creditcard.first_name.blank?
        creditcard.last_name = NameForgery.last_name if !creditcard.last_name.blank?
        creditcard.start_month = 11 if !creditcard.start_month.blank?
        creditcard.start_year = 2008 if !creditcard.start_year.blank?
        creditcard.issue_number = 1 if !creditcard.issue_number.blank?
        creditcard.save!
      end
      puts "Creditcards anonymized"
    end
    
    def self.anonymize_creditcard_txns
      CreditcardTxn.all.each do |creditcard_txn|
        creditcard_txn.response_code = '12345' if !creditcard_txn.response_code.blank?
        creditcard_txn.avs_response = 'avs' if !creditcard_txn.avs_response.blank?
        creditcard_txn.cvv_response = 'cvv' if !creditcard_txn.cvv_response.blank?
        creditcard_txn.save!
      end
      puts "CreditcardTxns anonymized"
    end
    
    def self.anonymize_gateway_option_values
      GatewayOptionValue.all.each do |gov|
        if !gov.value.blank?
          # Is this too heavy handed, don't want to risk passing around
          # sensitive payment gateway config.
          gov.value = 'Original value removed by DbTools::Anonymizer'
          gov.save!
        end
      end
      puts "GatewayOptionValues anonymized (is this too heavy handed?)"
    end
    
    def self.anonymize_shipments
      Shipment.all.each do |shipment|
        if !shipment.tracking.blank?
          shipment.tracking = BasicForgery.text
          shipment.save!
        end
      end
      puts "Shipments anonymized"
    end
    
    def self.anonymize_users
      User.all(:include => :roles).each do |user|
        if !user.has_role?('admin')
          # Preserve admin emails as you'll probably want them for testing, so
          # only change customer emails.
          email = InternetForgery.email_address
          user.login = email if !user.login.blank?
          user.email = email if !user.email.blank?
        end
        if (!user.password.blank?)
          password = BasicForgery.password
          user.password = password
          user.password_confirmation = password
        end
        user.current_login_ip = ip_address if !user.current_login_ip.blank?
        user.last_login_ip = ip_address if !user.last_login_ip.blank?
        # Not certain if changing these tokens is a good idea or needed.
        user.remember_token = BasicForgery.text if !user.remember_token.blank?
        user.persistence_token = BasicForgery.text if !user.persistence_token.blank?
        user.single_access_token = BasicForgery.text if !user.single_access_token.blank?
        user.perishable_token = BasicForgery.text if !user.perishable_token.blank?
        user.save!
      end
      puts "Users anonymized (admin emails preserved)"
    end
    
    # Override this method if you have your own anonymization to do, e.g. to
    # non-Spree-core tables.
    def self.anonymize_custom
      puts "NOTE: Override DbTools::Anonymizer.anonymize_custom if you want to add your own anonymization steps"
    end
    
  end
end