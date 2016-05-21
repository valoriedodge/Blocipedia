class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :created_wikis, dependent: :destroy, class_name: "Wiki"

  has_many :collaborations
  has_many :collaborating_wikis, through: :collaborations, class_name: "Wiki", source: :wiki

  before_save {self.email = email.downcase}
  after_initialize { self.role ||= :standard}

  enum role: [:standard, :premium, :admin]

  def downgrade
    self.standard!
    self.created_wikis.each { |wiki| wiki.make_public }
    save
  end

  def authorize_user
      wiki = Wiki.find(params[:id])

      unless current_user == wiki.creator || current_user.admin?
          flash[:alert] = "You must be an admin to do that."
          redirect_to wikis_path
      end
  end

end
