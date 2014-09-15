# Pool and Primer classes inherit from this class which allows these tables to be in a different database if desired
# To activate this capability, define oligo_inventory database in database.yml and use establish_connection command here
# To connect to different databases for different environments (development, test, production), define the different
# databases in database.yml, and use an if test on RAILS_ENV variable to determine which to connect to
# Eg: if RAILS_ENV == 'development'  establish_connection(:oligo_dev)
class InventoryDB < ActiveRecord::Base
  self.abstract_class = true
  #establish_connection(:oligo_inventory)
end

