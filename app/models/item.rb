# == Schema Information
#
# Table name: items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  po_number        :string(20)
#  requester_name   :string(30)
#  deliver_site     :string(4)
#  item_description :string(255)
#  company_name     :string(50)
#  catalog_nr       :string(50)
#  chemical_flag    :string(1)
#  item_size        :string(50)
#  item_quantity    :string(25)
#  item_quote       :string(100)
#  item_price       :decimal(9, 2)
#  item_received    :string(1)
#  grant_nr         :string(30)
#  notes            :string(255)
#  created_at       :datetime
#  updated_at       :timestamp
#  updated_by       :integer
#

class Item < ActiveRecord::Base
  belongs_to :order
  
  validates_presence_of :requester_name, :company_name, :chemical_flag, :catalog_nr,
                        :item_description, :item_quantity, :deliver_site
                        
  DELIVER_SITES = %w{SGTC CCSR}

  def item_ext_price
    ((item_quantity.nil? || item_price.nil?) ? nil : item_quantity.to_i * item_price)
  end

  def ordered?
    !(order_id.nil? || order_id == 0)
    #!(po_number.nil? || po_number.blank?)
    #requester_name > 'S'  #for testing purposes only
  end
  
  def requester_abbrev
    if requester_name.nil? || requester_name.length < 11
      req_nm = requester_name
    else
      first_and_last = requester_name.split(' ')
      req_nm = [first_and_last[0], first_and_last[1][0,1]].join(' ')
    end
    return req_nm
  end
  
  def self.find_all_unique(condition_array=[])
    self.where(sql_where(condition_array)).group('item_description, catalog_nr').all
    #self.find(:all, :group => "item_description, catalog_nr",
    #               :conditions => condition_array)
  end
  
  def self.find_all_by_date(condition_array=[])
    self.includes(:order).where(sql_where(condition_array)).order('DATE(items.created_at) DESC, orders.po_number').all
    #self.find(:all, :include => :order,
    #                :order => 'DATE(items.created_at) DESC, orders.po_number',
    #                :conditions => condition_array)
  end
  
  def self.find_all_unordered
    self.find_all_by_date(['items.order_id = 0 OR items.order_id IS NULL'])
  end
  
  def self.includes_chemical?(id_list)
    @_list ||= self.find_by_id(:all, id_list).collect(&:chemical_flag)
    (@_list.include?('Y') )
  end
  
  def self.upd_orderid(order_id, item_ids)
    item_ids.each do |item_id|
      item = self.find(item_id)
      item.update_attributes(:order_id => order_id)
    end
  end
  
  def self.upd_items_recvd_for_order(order_id, order_received)
    self.update_all("item_received = '#{order_received}'", "order_id = #{order_id}")
  end
  
protected
  def validate
    if !item_price.nil? 
      errors.add(:item_price, "must be numeric and at least 0.01") if Float(item_price) < 0.01
    end
  end
  
end
