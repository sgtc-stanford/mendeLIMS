## == Schema Information
#
# Table name: pools
#
#  id                  :integer          not null, primary key
#  pool_name           :string(35)       not null
#  tube_label          :string(15)       not null
#  pool_description    :string(80)
#  from_pools          :string(100)
#  from_plates         :string(100)
#  total_oligos        :integer          default(0), not null
#  cherrypick_oligos   :integer          default(0), not null
#  enzyme_code         :string(50)
#  source_conc_um      :decimal(8, 3)
#  pool_volume         :decimal(8, 3)
#  project_id          :integer
#  storage_location_id :integer
#  notes               :string(255)
#  updated_at          :timestamp
#

class Pool < InventoryDB
  has_and_belongs_to_many :primers
  validates_presence_of :pool_name, :tube_label
  validates_uniqueness_of :pool_name, :tube_label
  
  USING_POOLS = (self.nil? || (self.first.total_oligos == 0 && self.all.size == 1) ? nil : 'yes')

  HUMAN_ATTRIBUTE_NAMES = {
    :pool_name => [POOL_TYPE, ' Pool'].join,
    :gene_code => 'Gene'
  }

  class << self
    def human_attribute_name attribute_name
      HUMAN_ATTRIBUTE_NAMES[attribute_name.to_sym] || super(name, *args)
    end
  end
 
  def pool_string
    if tube_label[0,2] == 'PP' 
      return pool_string_dtl
    else
      return tube_label
    end
  end
  
  def pool_string_dtl
    return [tube_label, pool_name].join('/')
  end
  
  def self.get_pool_name(id=nil)
    pool = self.find(id) if !id.nil?
    return (pool.nil? ? '' : pool.pool_name)
  end
  
  def self.get_pool_label(id=nil)
    pool = self.find(id) if !id.nil?
    return (pool.nil? ? '' : pool.tube_label)
  end
  
  def self.populate_dropdown(lib_or_flowcell='lib')
    if lib_or_flowcell == 'lib'
      sql_condition = "LEFT(tube_label,2) != 'OS'"
    else
      sql_condition = "LEFT(tube_label,2) IN ('OS', 'PP')"
    end
    return self.order(:tube_label).where(sql_condition).all
  end

end
