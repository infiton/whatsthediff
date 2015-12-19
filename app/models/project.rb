class Project < ActiveRecord::Base
  include AASM
  obfuscate_id spin: 8675309

  belongs_to :user
  validates_presence_of :user

  aasm column: :state do
    state :new, initial: true
  end
end
