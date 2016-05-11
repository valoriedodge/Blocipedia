class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :wikis, dependent: :destroy
  before_save {self.email = email.downcase}
  after_initialize { self.role ||= :standard}

  enum role: [:standard, :premium, :admin]

  def downgrade
    self.standard!
    self.wikis.each { |wiki| wiki.make_public }
    save
  end

  def authorize_user
      wiki = Wiki.find(params[:id])

      unless current_user == post.user || current_user.admin?
          flash[:alert] = "You must be an admin to do that."
          redirect_to wikis_path
      end
  end

end
