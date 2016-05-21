class WikisController < ApplicationController
  before_action :require_sign_in, except: [:index, :show]

  def index
    @wikis = policy_scope(Wiki)
    #if current_user
    #  @wikis = Wiki.visible_to(current_user)
    #else
    #  @wikis = Wiki.where(private: false)
    #end
  end

  def show
    @wiki = Wiki.find(params[:id])
    unless !@wiki.private
      if (current_user.admin? || @wiki.creator = current_user || @wiki.collaborators.include?(current_user))
        @wiki = Wiki.find(params[:id])
      else
        flash[:alert] = "You must be authorized to view private wikis."
        redirect_to wikis_path
      end
    end
  end

  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new
    @wiki.assign_attributes(wiki_params)
    @wiki.creator = current_user
    collaborator = User.find_by_email(params[:collaborator_email])
    #collaborator = User.find_by_email(:collaborators)
    #@wiki.collaborators = []

    if @wiki.save
      if collaborator
        @wiki.collaborators << collaborator
      end
      flash[:notice] = "\"#{@wiki.title}\" was created successfully."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error creating the wiki. Please try again."
      render :new
    end
  end

  def edit

    @wiki = Wiki.find(params[:id])
    unless !@wiki.private
      if (current_user.admin? || @wiki.creator = current_user || @wiki.collaborators.include?(current_user) )
        @body = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(@wiki.body)
      else
        flash[:alert] = "You must be authorized to edit private wikis."
        redirect_to wikis_path
      end
    end
  end

  def update
    @wiki = Wiki.find(params[:id])
    @wiki.assign_attributes(wiki_params)
    collaborator = User.find_by_email(params[:collaborator_email])
    #collaborator = User.find_by_email(:email)
    #@wiki.collaborators = []

    if @wiki.save
      if collaborator && !@wiki.collaborators.include?(collaborator)
        @wiki.collaborators << collaborator
      end
      #@wiki.collaborators << Collaboration.update_collaborators(params[:wiki][:collaborators])
      flash[:notice] = "\"#{@wiki.title}\" was updated successfully."
    else
      flash.now[:alert] = "There was an error updating the wiki."
    end
    render :edit
  end

  def destroy

    #if (current_user.admin? || @wiki.creator = current_user )
        @wiki = Wiki.find(params[:id])
    #else
    #    flash[:alert] = "You must be authorized to delete other wikis."
    #    redirect_to wikis_path
    #end

    if @wiki.destroy
          flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
          redirect_to wikis_path
    else
          flash.now[:alert] = "There was an error deleting the wiki."
          render :show
    end
  end

  private

  def wiki_params
      params.require(:wiki).permit(:title, :body, :private)
  end

end
