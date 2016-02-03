# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

data_file_path = File.join(Rails.root, 'db', 'data_files')

##########################################################################################
### Populate user and roles tables                                                     ###
##########################################################################################

# Create initial entries for roles table (unless already exist)
%w{admin clin_admin clinical researcher lab_admin alignment orders barcodes}.each do |role|
  Role.find_or_create_by_name(role)
end

# Create admin user, with admin role (unless already exists)
if !User.find_by_login('admin')
  user = User.create(:login => 'admin',
                     :email => 'youremail@yourdomain.com',
                     :password => 'LIMS!pswd',
                     :password_confirmation => 'LIMS!pswd')
  user.roles << Role.find_by_name('admin')
  user.save!             
end

# Create researcher, linked to admin user (unless already exists)
admin_user = User.find_by_login('admin')
if admin_user && !Researcher.find_by_user_id(admin_user.id)
  Researcher.create!(:user_id => admin_user.id,
                     :researcher_name => 'Admin User',
                     :researcher_initials => 'AU',
                     :active_inactive => 'A')
end

##########################################################################################
### Populate tables for category drop-down lists                                       ###
##########################################################################################
# Truncate all category related tables
CategoryValue.connection.execute("TRUNCATE TABLE category_values")
Category.connection.execute("TRUNCATE TABLE categories")
Cgroup.connection.execute("TRUNCATE TABLE cgroups")

# Populate category groups
['Clinical', 'Sample', 'Extraction', 'Seq Library', 'Sequencing', 'Pathology', 'Histology', 'Other', 'Orders'].each_with_index do |cgrp, i|
  Cgroup.create!(:group_name => cgrp, :sort_order => i+1)
end

# Populate categories
file_path = File.join(data_file_path, 'categories.txt')
if FileTest.file?(file_path)
  File.open(file_path, 'r') do |file|
    file.read.each_line do |category|
      cgroup_id, category, category_description = category.chomp.split("\t")
      Category.create!(:cgroup_id => cgroup_id, 
                       :category => category,
                       :category_description => category_description)
    end
  end
end

# Populate category values
file_path = File.join(data_file_path, 'category_values.txt')
if FileTest.file?(file_path)
  File.open(file_path, 'r') do |file|
    file.read.each_line do |cat_value|
      @category_name, c_position, c_value = cat_value.chomp.split("\t")
      if !@category || @category.category != @category_name
        @category = Category.find_by_category(@category_name)
      end
      CategoryValue.create!(:category_id => @category.id, 
                            :c_position => c_position,
                            :c_value => c_value)
    end
  end
end

##########################################################################################
### Populate tables for alignment references, sequencing machines                      ###
##########################################################################################
# Truncate alignment reference and sequencing machine tables
AlignmentRef.connection.execute("TRUNCATE TABLE alignment_refs")
SeqMachine.connection.execute("TRUNCATE TABLE seq_machines")

# Populate sequencing machines
%w{Run_Number SG1 SG2}.each do |machine|
  SeqMachine.create!(:machine_name => machine,
                     :machine_type => (machine == 'Run_Number' ? nil : 'GAIIx'),
                     :last_seq_num => (machine == 'Run_Number' ? 0 : nil))
  end
  
# Populate alignment reference(s)
AlignmentRef.create!(:alignment_key => 'HWG_37.1',
                     :genome_build => '37.1')
                     
##########################################################################################
### Populate tables for sample storage locations                                       ###
##########################################################################################
FreezerLocation.connection.execute("TRUNCATE TABLE freezer_locations")

FreezerLocation.create!(:room_nr => '123',
                        :freezer_nr => '1')
                        
##########################################################################################
### Populate tables for sequencing data disks/directories                              ###
##########################################################################################
StorageDevice.connection.execute("TRUNCATE TABLE storage_devices")

StorageDevice.create!(:device_name => 'Disk1',
                      :building_loc => 'Building1',
                      :base_run_dir => '/')

##########################################################################################
### Populate tables for consent protocols                                              ###
##########################################################################################
ConsentProtocol.connection.execute("TRUNCATE TABLE consent_protocols")

[['NA', 'Anonymous Sample'], ['1123', 'Consent Protocol']].each do |consent|
  ConsentProtocol.create!(:consent_nr   => consent[0],
                          :consent_name => consent[1],
                          :consent_abbrev => consent[1])
end

##########################################################################################
### Populate tables for assay protocols                                                ###
##########################################################################################
Protocol.connection.execute("TRUNCATE TABLE protocols")

file_path = File.join(data_file_path, 'protocols.txt')
if FileTest.file?(file_path)
  File.open(file_path, 'r') do |file|
    file.read.each_line do |protocol|
      name, abbrev, ptype, pcode = protocol.chomp.split("\t")
      Protocol.create!(:protocol_name   => name, 
                       :protocol_abbrev => abbrev,
                       :protocol_type   => ptype,
                       :protocol_code   => pcode)
    end
  end
end

##########################################################################################
### Populate tables for multiplex tags                                                 ###
##########################################################################################
IndexTag.connection.execute("TRUNCATE TABLE index_tags")

file_path = File.join(data_file_path, 'index_tags.txt')
if FileTest.file?(file_path)
  File.open(file_path, 'r') do |file|
    file.read.each_line do |index_tag|
      adapter, tag_nr, sequence = index_tag.chomp.split("\t")
      IndexTag.create!(:runtype_adapter => adapter, 
                       :tag_nr          => tag_nr,
                       :tag_sequence    => sequence)
    end
  end
end

##########################################################################################
### Populate tables for oligo pools                                                    ###
##########################################################################################
Pool.connection.execute("TRUNCATE TABLE pools")

Pool.create!(:pool_name  => 'ProjectOrPool',
             :tube_label => 'XX0001',
             :pool_description => 'Test project/pool')

