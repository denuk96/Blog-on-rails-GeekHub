class PostsController < ApplicationController
  # impressionist
  impressionist actions: [:show]

  before_action :require_login, only: %i[create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :owner, only: %i[edit update destroy]



  def index

    @posts = Post.all.order('created_at DESC')
    @posts = if params[:search]
               Post.search(params[:search]).order('created_at DESC')
             else
               Post.all.order('created_at DESC')
             end
  end

  def show
    # impressionist
    impressionist(@post)
  end

  def new
    @post = Post.new
  end

  def edit; end

  def create
    if @current_user.banned == false
      @post = current_user.posts.build(post_params)
      respond_to do |format|
        if @post.save
          format.html { redirect_to @post, notice: 'Post was successfully created.' }
          format.json { render :show, status: :created, location: @post }
        else
          format.html { render :new }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to home_path, notice: 'Aborted. You are banned.'
    end
  end

  def update
    # If not a owner/admin - you cant edit/destroy
    redirect_to home_path if owner == false

    respond_to do |format|
      if @post.update_attributes(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  # checking owner or not
  def owner
    if (@post.author_id == @current_user.id && Time.now - @post.created_at < 3601 && @current_user.banned == false) || (@current_user.admin == true)
    else
      respond_to do |format|
        format.html { redirect_to posts_url, alert: 'Rights error' }
      end
    end
  end

  def post_params
    params.require(:post).permit(:title, :content, :author_id, :picture)
  end
end
