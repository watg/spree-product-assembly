class Spree::AssembliesPart < ActiveRecord::Base
  belongs_to :assembly, :polymorphic => true 
  belongs_to :part, :class_name => "Spree::Variant", :foreign_key => "part_id"
end
