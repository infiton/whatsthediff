class Project < ActiveRecord::Base
  include AASM
  serialize :field_signature, JSON

  belongs_to :user
  belongs_to :target_user, class_name: "User"

  has_many :source_rows, -> { source }, class_name: "ProjectRow", dependent: :delete_all
  has_many :target_rows, -> { target }, class_name: "ProjectRow", dependent: :delete_all

  has_many :results, class_name: "ProjectResult", dependent: :delete_all

  validates :user, presence: true
  validates :field_signature, presence: true, :if => :configured?
  validates :target_user, presence: true, :if => :target_selected?

  before_create :set_slug

  aasm column: :state, whiny_transitions: false do
    state :new, initial: true
    state :configured
    state :source_uploaded
    state :target_selected
    state :target_uploaded
    state :completed

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

    event :finalize_target do
      after do
        ProjectDiffJob.perform_later(self)
      end
      transitions from: :target_selected, to: :target_uploaded
    end

    event :complete do
      transitions from: :target_uploaded, to: :completed
    end
  end

  #convenience method to keep the source/target semantics consistent
  def source_user
    user
  end
  #we override to_param to use slug for our restful controller actions
  def to_param
    slug
  end

  def target_rows_size
    rows_size(:target)
  end

  def source_rows_size
    rows_size(:source)
  end  

  def humanized_fields
    return [] unless field_signature.respond_to?(:map)
    field_signature.map(&:humanize)
  end

  def result_files
    results.map{|r| [r.result_type,r.id]}.to_h
  end

  private
    def rows_size(type)
      send("#{type}_rows").size
    end

    def set_configs(configs)
      if configs[:field_signature]
        self.field_signature = configs[:field_signature]
      end
    end

    def set_target(target)
      self.target_user = target
    end

    def set_slug
      self.slug = SecureRandom.hex
    end
end
