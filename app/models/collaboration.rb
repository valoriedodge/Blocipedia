class Collaboration < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki

  #validates :user, uniqueness: {scope: :wiki}
  #validates :wiki, uniqueness: {scope: :user}

  #def self.update_collaborators(user)
     #return Collaboration.none if user.blank?

     #collaborator_string.split(",").map do |email|
     #@user = User.find_by_email(email_string)
    #Collaboration.find_or_create_by(user: user)
   #end
end
