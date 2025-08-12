class HomeController < ApplicationController
  def index
    @featured_products = Product.active.featured.limit(8)
    @recent_products = Product.active.recent.limit(8)
    @popular_products = Product.active.popular.limit(8)
    @categories = Category.active.root_categories.ordered.limit(6)
    @stores = Store.active.verified.limit(4)
  end

  def about
  end

  def contact
  end

  def help
  end

  def terms
  end

  def privacy
  end

  def faq
  end
end
