class PostsController < ApplicationController

  def index
    @posts = Post.includes(:user, :liked_users, {visible_comments: :user}).page(params[:page])
    post_ids = @posts.map{|p| p.id }
    @subscriptions_count = Post.where( id: post_ids).joins(:subscriptions).group("posts.id").count
  end

  def show
    @post = Post.find(params[:id])
    if current_user
      all_comments = @post.comments.where( "status = ? OR ( status = ? AND user_id =?)", "public", "private", current_user.id).includes(:user)
    @comments = all_comments.select{ |x| x.status == "public" }
    @my_comments = all_comments.select{ |x| x.status == "private" }
    
    else
      @comments = @post.comments.visible.includes(:user)
    end
  end

  def report
    @posts = Post.includes(:user).joins(:subscriptions).group("posts.id").select("posts.*, COUNT(subscriptions.id) as subscription_count").order("subscription_count DESC").limit(10)
  end

end
