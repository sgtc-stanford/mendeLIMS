class InventoryDB < ActiveRecord::Base
  self.abstract_class = true
  #establish_connection(:oligo_inventory) if !DEMO_APP
end