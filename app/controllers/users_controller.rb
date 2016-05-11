class UsersController < ApplicationController
 def downgrade
   if current_user.downgrade
     flash[:notice] = "Premium membership cancelled successfully."
   else
     flash.now[:alert] = "There was an error cancelling your premium membership."
   end
  redirect_to wikis_path
 end

end
