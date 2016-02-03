# Authorization rules, using authorization gem: "cancan"
# Add the following code in all controllers for which authorization should apply:
#   load_and_authorize_resource

# Any common non-RESTful actions across controllers can be mapped to a standard action such 
# as 'read' using 'alias_action', below.
# Alternatively, can restrict access within a specific controller method with:
#   authorize! :action, model_object

# In views, to test whether the current user has permissions to perform a given 'action' on a
# specific 'model_object', use: 
#    if can? :action, model_object

# rescue clause for unauthorized actions, is in application controller.

class Ability
  include CanCan::Ability
  
  def initialize(user=current_user)
    alias_action :setup_params, :query_params, :new_query, :list_selected, :index, :show, :show_qc, :to => :read
    
    # Everyone can read all data, and enter order items, but cannot read for patient tables
    can :read, :all
    
    # Everyone can create a new user, or view/edit their own user information
    can [:new, :create, :forgot, :reset], User
    can [:show, :edit, :update], User do |usr|
      (!DEMO_APP && user.has_role?("admin")? true : usr.login == user.login)   
    end
    
    # Everyone can enter order items
    can :manage, Item
    cannot :delete, Item
    can [:edit, :edit_order_items, :update], Order
    
    # No-one can read patient data unless authorization overridden based on role below
    cannot :read, Patient
    
    return nil if user == :false

    # Admins have access to all functionality
    if user.has_role?("admin")
      can :manage, :all
      cannot :delete, Category if DEMO_APP
    else
      # Researchers can enter/update processed samples, seq libs, flow cells
      if user.has_role?("researcher") || user.has_role?("lab_admin")
        can :manage, [Sample, ProcessedSample, MolecularAssay, SeqLib, LibSample, FlowCell,
                      FlowLane, Protocol, FreezerLocation, Researcher, Publication]
        cannot [:edit, :update, :delete], Sample
      end
    
      # Clinical users can enter/update patient and clinical samples
      if user.has_role?("clinical") || user.has_role?("clin_admin")
        can :manage, [Patient, SampleCharacteristic, Pathology, Sample, Histology, ProcessedSample, MolecularAssay, Publication]
        cannot :delete, [Patient, SampleCharacteristic, Sample]
      end
      
      # Additional capabilities for clin_admin (update users, consent_protocols, locations)
      if user.has_role?("clin_admin")
#        can :read, User
#        can [:edit, :update], User do |usr| 
#          @_roles ||= usr.roles.collect(&:name)
#          @_roles.include?("clinical") || usr == user
#        end
        
        can :manage, [ConsentProtocol, Protocol, FreezerLocation]
        cannot :delete, ConsentProtocol            
      end
      
      # Additional capabilities for clin_admin or lab_admin (update drop-down list values)
      if user.has_role?("clin_admin") && user.has_role?("lab_admin")
        can [:edit, :update], Category 
        can :manage, CategoryValue
        
      elsif user.has_role?("clin_admin")
        can [:edit, :update], Category do |cval|
          [1,2,3,6,7,9].include?(cval.cgroup_id)    # Drop-down lists for samples, orders
        end
        can :manage, CategoryValue do |val|
          [1,2,3,6,7,9].include?(val.category.cgroup_id)
        end
       
      elsif user.has_role?("lab_admin")
        can [:edit, :update], Category do |cval|
          [4,5].include?(cval.cgroup_id)    # Drop-down lists for seq libraries, sequencing
        end 
        can :manage, CategoryValue do |val|
          [4,5].include?(val.category.cgroup_id)
        end
      end
      
      # Alignment users can enter/update alignment/qc results, alignment refs
      if user.has_role?("alignment")
        can :manage, [SeqLib, LibSample, FlowCell, FlowLane, AlignQc, AlignmentRef, SeqMachine, StorageDevice, RunDir]
        cannot :delete, [AlignmentRef, SeqMachine]
      end
      
      if user.has_role?("barcodes")
        can :manage, AssignedBarcode
      end
      
      # Orders users can create orders
      if user.has_role?("orders")
        can [:read, :new, :create, :edit, :update], Order
      end
      
    end
  end
  
end