class ArticlesController < ApplicationController
  # http_basic_authenticate_with name: "merna", password: "secret", except: [:index, :show]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @articles = policy_scope(Article)
  end

  def show
    @article = Article.find(params[:id])
    authorize @article
  end

  def new
    @article = current_user.articles.build
    authorize @article
  end

  def create
    @article =  current_user.articles.build(article_params)
    authorize @article

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
    authorize @article
  end

  def update
    @article = Article.find(params[:id])
    authorize @article

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    authorize @article
    @article.destroy
    redirect_to root_path, status: :see_other
  end

  def report
    @article = Article.find(params[:id])
    @article.report!
    redirect_to root_path
  end


  private
    def article_params
      params.require(:article).permit(:title, :body, :status, :image)
    end
end
