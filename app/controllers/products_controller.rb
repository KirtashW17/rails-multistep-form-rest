class ProductsController < ApplicationController
  before_action :load_product
  before_action :set_form_builder, except: [:show, :index]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @wizard = ModelWizard.new(Product, params).start
    @product = @wizard.object
  end

  def edit
    @wizard = ModelWizard.new(@product, params).start
  end

  def create
    @wizard = ModelWizard.new(Product, params, product_params).continue
    @product = @wizard.object
    if @wizard.save
      redirect_to @product, notice: "Product created!"
    else
      render :new
    end
  end

  def update
    @wizard = ModelWizard.new(@product, params, product_params).continue
    if @wizard.save
      redirect_to @product, notice: 'Product updated.'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url
  end

private

  def load_product
    @product = Product.find_by(id: params[:id])
  end

  def product_params
    return params unless params[:product]

    params.require(:product).permit(:current_step,
      :name,
      :description,
      :price,
      :quantity,
      :"available_at(1i)",
      :"available_at(2i)",
      :"available_at(3i)",
      :"available_at(4i)",
      :"available_at(5i)",
      :tags,
      :categories_attributes => [:id, :name]
    )
  end

  private

  def set_form_builder
    @form_builder, @partial =
      if params[:all]
        [ActionView::Helpers::FormBuilder, "products/steps/all_steps"]
      else
        [ModelWizardFormBuilder, "products/steps/current_step"]
      end
  end

end
