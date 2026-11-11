module Admin
  class ProductsController < BaseController
    require_permission :manage_products

    def index
      @products = Product.not_archived
        .includes(:product_category, cover_photo: { image_attachment: :blob })
        .select("products.*", "(SELECT COUNT(*) FROM product_photos WHERE product_photos.product_id = products.id) AS photos_count")
        .order(updated_at: :desc, id: :desc)
      @total_count = Product.not_archived.count
    end
  end
end
