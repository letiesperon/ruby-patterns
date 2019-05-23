class ArticlesQuery
  attr_reader :relation

  def initialize(relation = Article.all)
    @relation = relation
  end

  def published
    # method implementation ...
  end

  private

  def custom_sql
    # custom SQL query ...
  end
end

ArticlesQuery.new.published
