class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_many :projects

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def collect_from params
  	params.each do |param,value|
  		self.send((param.to_s) + "=", value) unless value.to_s.empty?
  	end
  	self
  end

  def collect_from! params
  	self.collect_from params
  	self.save
  end
end