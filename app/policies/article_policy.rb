class ArticlePolicy < ApplicationPolicy
  attr_reader :user, :article

  def initialize(user, article)
    @user = user
    @article = article
  end

  def index?
    true  
  end

  def show?
    !article.archived? && (article.public? || user_owns_article?)
  end
  
  def create?
    user.present?
  end

  def update?
    user_owns_article?
  end

  def destroy?
    user_owns_article?
  end

  def report?
    user.present? && article.user_id != user.id
  end

  private

  def user_owns_article?
    user.present? && article.user_id == user.id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.present?
        scope.where("status = 'public' OR user_id = ?", user.id)
      else
        scope.where(status: 'public')
      end
    end
  end
end
