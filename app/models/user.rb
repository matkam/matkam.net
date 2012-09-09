class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  # Need to specify "source" field in order to use "followed_users"
  # association array, instead of more awkward "followeds"
  has_many :followed_users, through: :relationships, source: :followed 
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
				   dependent: :destroy
  has_many :followers, through: :reverse_relationships
  
  before_save { self.email.downcase! }
  before_save :create_remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,	presence: true, length:	{ maximum: 50 }
  validates :email,	presence: true,
			format: { with: VALID_EMAIL_REGEX },
			uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end
  
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end
  
  private
  
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
    
end
