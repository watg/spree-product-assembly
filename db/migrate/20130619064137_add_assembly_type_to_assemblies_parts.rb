class AddAssemblyTypeToAssembliesParts < ActiveRecord::Migration

  def self.up
    table = if table_exists?(:assemblies_parts)
      'assemblies_parts'
    elsif table_exists?(:spree_assemblies_parts)
      'spree_assemblies_parts'
    end 
    
    change_table(table) do |t|
       t.column :assembly_type, :string, :limit =>32 , :null => false, :default => 'Spree::Product'
    end
 
    add_index table, [:assembly_type, :assembly_id], :name => 'assembly_by_type_and_id'
  end


  def self.down

  table = if table_exists?(:assemblies_parts)
      'assemblies_parts'
    elsif table_exists?(:spree_assemblies_parts)
      'spree_assemblies_parts'
    end 

    remove_index table, :name => 'assembly_by_type_and_id'
    change_table(table) do |t|
       t.remove :assembly_type
    end
  end

end
