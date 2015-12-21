class Project < ActiveRecord::Base
  include AASM
  obfuscate_id spin: 8675309

  belongs_to :user
  has_many :source_rows, -> { source }, class_name: "ProjectRow", dependent: :delete_all
  has_many :target_rows, -> { target }, class_name: "ProjectRow", dependent: :delete_all

  validates :user, presence: true
  validates :field_signature, presence: true, :if => :configured?

  aasm column: :state, whiny_transitions: false do
    state :new, initial: true
    state :configured

    event :configure do
      before do |*args|
        set_configs(*args)
      end

      transitions from: :new, to: :configured
    end
  end

  private
    def set_configs(configs)
      if configs[:field_signature]
        self.field_signature = ActiveSupport::JSON.encode(configs[:field_signature])
      end
    end
end
