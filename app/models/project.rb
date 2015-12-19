class Project < ActiveRecord::Base
  include AASM
  obfuscate_id spin: 8675309

  belongs_to :user

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

  def load_data_chunk(data_type,chunk)
    binding.pry
  end

  private
    def set_configs(configs)
      if configs[:field_signature]
        self.field_signature = ActiveSupport::JSON.encode(configs[:field_signature])
      end
    end
end
