class UsersController < ApplicationController
 def downgrade
   user = current_user
   user.downgrade(user)
   if user.save
     flash[:notice] = "Premium membership cancelled successfully."
     redirect_to wikis_path
   else
     flash.now[:alert] = "There was an error cancelling your premium membership."
     redirect_to wikis_path
   end
 end
end
