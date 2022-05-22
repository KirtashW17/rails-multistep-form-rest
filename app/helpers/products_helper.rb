module ProductsHelper
  def build_product(product, multi_step)
    product.categories.build if product.categories.empty? and (product.step2? or multi_step)
    product
  end
end
