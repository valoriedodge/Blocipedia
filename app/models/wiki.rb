class Wiki < ActiveRecord::Base
  belongs_to :creator, class_name: "User", foreign_key: :user_id

  has_many :collaborations
  has_many :collaborators, through: :collaborations, class_name: "User", source: :user
  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 10 }, presence: true
  after_initialize { self.private ||= false}

  scope :visible_to, -> (user) { user.standard? ? where(private: false) : all }

  def make_public
    self.private = false
    save
  end

end
