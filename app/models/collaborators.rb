class Collaborator < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki

  def self.update_collaborators(collaborator_string)
     return Collaborator.none if collaborator_string.blank?

     collaborator_string.split(",").map do |email|
       user = User.find(params[email.strip])
       Collaborator.find_or_create_by(user_id: user.id)
     end
   end
end
