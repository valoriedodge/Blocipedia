class WikisController < ApplicationController
  before_action :require_sign_in, except: [:index, :show]

  def index
    if current_user
      @wikis = Wiki.visible_to(current_user)
    else
      @wikis = Wiki.where(private: false)
    end
  end

  def show
    @wiki = Wiki.find(params[:id])
    unless !@wiki.private
      if current_user && (current_user.admin? || current_user.premium?)
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
    @wiki.user = current_user

    if @wiki.save
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
      if current_user && (current_user.admin? || current_user.premium?)
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

    if @wiki.save
      flash[:notice] = "\"#{@wiki.title}\" was updated successfully."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error updating the wiki."
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])

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
