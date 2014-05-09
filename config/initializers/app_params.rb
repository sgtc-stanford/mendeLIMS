environment_file = "#{Rails.root}/app/assets/system/environment.txt"
email_file       = "#{Rails.root}/app/assets/system/emails.txt"
ezkeys_file      = "#{Rails.root}/app/assets/system/ez_keys.txt"
version_file     = "#{Rails.root}/app/assets/system/app_versions.txt"

require 'active_record_extension'
require 'csv'

if FileTest.file?(environment_file)
  env_array = CSV.read(environment_file, {:col_sep => "\t"})
  APP_TYPE = env_array[0][0][0..3].upcase
  SITE_URL = env_array[0][1] 
  APP_TAGLINE = ((env_array.size > 1 && env_array[1][0] = 'Tagline')? env_array[1][1] : '')
  POOL_TYPE = (APP_TAGLINE =~ /Ji/ ? 'Oligo' : 'Primer')
  SEQ_ORDER = (APP_TAGLINE =~ /Mindrinos/ ? 'seqdt' : 'runnr')
end

DEMO_APP = (APP_TYPE == 'DEMO'? true : false)
DEMO_USERS = ['admin', 'clinical', 'researcher']

#Email configuration parameters #
#Contents of .txt file (tab-delimited) expected to be: 
# Send_From <Email>               where <Email> is email address to be used for sending emails from the system
# Admin_To  <Email>               where <Email> is email address of system admin (debug emails will be sent here)

# Samples_Email <Env>             where <Env> is either Production, Test, or NoEmail
# Samples_Delivery  <Delivery>    where <Delivery> is Deliver, Debug or None
# Samples_To  <Email>             where <Email> is comma-separated list of email addresses to which new samples should be sent

# Orders_Email <Env>              where <Env> is either Production, Test, or NoEmail
# Orders_Delivery <Delivery>      where <Delivery> is Deliver, Debug or None
# Orders_To <Email>               where <Email> is comma-separated list of email addresses to which new orders should be sent

EMAIL_CREATE = {}
EMAIL_TO = {}
EMAIL_DELIVERY = {}

if FileTest.file?(email_file)
  CSV.foreach(email_file, {:col_sep => "\t"}) do |erow|
    case
    when erow[0] == 'Send_From'
      EMAIL_FROM = erow[1]
    when erow[0].match(/_Email/)
      EMAIL_CREATE.merge!(erow[0][0..-7].downcase.to_sym => erow[1]) # Strip off _Email
    when erow[0].match(/_To/)
      EMAIL_TO.merge!(erow[0][0..-4].downcase.to_sym => erow[1]) # Strip off _To
    when erow[0].match(/_Delivery/)
      EMAIL_DELIVERY.merge!(erow[0][0..-10].downcase.to_sym => erow[1]) # Strip off _Delivery
    end
  end
end

#read keys for ezcrypto encryption/decryption
ez_arr = IO.readlines(ezkeys_file)
EZ_PSWD = ez_arr[0].chomp
EZ_SALT = ez_arr[1].chomp

#read App_Versions file to set current application version #
#version# is first row, first column
if FileTest.file?(version_file)
  File.open(version_file) do |file|
    filerow = file.gets
    APP_VERSION = filerow.split(/\t/)[0]
    file.close
  end
end

META_TAGS = {:description => "Stanford Genome Technology LIMS manages clinical samples, molecular assays and other processing related to high throughput resequencing operations",
             :keywords => ["stanford, LIMS, biological medicine, hanlee ji, genome, cancer, cancer research, dna sequencing"]}
