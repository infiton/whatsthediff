class Project < ActiveRecord::Base
  include AASM
  obfuscate_id spin: 8675309

  belongs_to :user
  belongs_to :target_user, class_name: "User"
  has_many :source_rows, -> { source }, class_name: "ProjectRow", dependent: :delete_all
  has_many :target_rows, -> { target }, class_name: "ProjectRow", dependent: :delete_all

  validates :user, presence: true
  validates :field_signature, presence: true, :if => :configured?
  validates :target_user, presence: true, :if => :target_selected?

  aasm column: :state, whiny_transitions: false do
    state :new, initial: true
    state :configured
    state :source_uploaded
    state :target_selected

    event :configure do
      before do |*args|
        set_configs(*args)
      end

      transitions from: :new, to: :configured
    end

    event :finalize_source do
      transitions from: :configured, to: :source_uploaded
    end

    event :select_target do
      before do |*args|
        set_target(*args)
      end

      transitions from: :source_uploaded, to: :target_selected
    end
  end

  private
    def set_configs(configs)
      if configs[:field_signature]
        self.field_signature = ActiveSupport::JSON.encode(configs[:field_signature])
      end
    end

    def set_target(target)
      self.target_user = target
    end
end
