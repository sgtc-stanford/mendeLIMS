# Configure action_mailer
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address              => 'your smtp server', # Eg. smtp.yourco.com
    :port                 => 25,
    :domain               => 'your domain',      # Eg. yourco.com
    :enable_starttls_auto => true
}