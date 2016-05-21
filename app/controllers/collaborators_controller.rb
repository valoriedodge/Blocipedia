class CollaboratorsController < ApplicationController
  def remove
        @wiki = Wiki.find(params[:wiki_id])
        collaborator = @wiki.collaborators.find(params[:id])

        if @wiki.collaborators.delete(collaborator)
            flash[:notice] = "Collaborator deleted."
        else
            flash[:alert] = "Deleting collaborator failed."
        end
        redirect_to wikis_path
    end
end
