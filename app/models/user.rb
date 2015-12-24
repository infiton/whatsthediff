class User < ActiveRecord::Base
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, 
    presence: true, 
    length: { maximum: 255 },
    format: { with: VALID_EMAIL },
    uniqueness: { case_sensitive: false }

  has_many :projects

  def display_name
    full_name ? full_name : email
  end

  def full_name
    return nil unless first_name || last_name
    [first_name, last_name].compact.join(" ")
  end
end
