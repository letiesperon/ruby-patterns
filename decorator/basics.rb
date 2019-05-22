class FacebookCommentNotifier
  def initialize(comment)
    @comment = comment
  end

  def save
    @comment.save && post_to_wall
  end

  private

  def post_to_wall
    Facebook.post(title: @comment.title, user: @comment.author)
  end
end

@comment = FacebookCommentNotifier.new(Comment.new(params[:comment]))
render_error unless @comment.save
