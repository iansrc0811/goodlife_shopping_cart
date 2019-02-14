class OrdersController < ApplicationController
  before_action :set_order, only: [:checkout, :edit_item, :remove_item, :edit, :show, :update, :destroy]

  def get_line_items
    if params[:order_id].present?
      order = current_user.orders.find(params[:order_id])
    else
      order = current_user.orders.cart.last || current_user.default_cart
    end
    item_array = order.items
    render json: { success: true, order_id: order.id, order_name: order.name, items: item_array, total_price: order.price }
  rescue => e
    render_failure(e.message)
  end

  def remove_item
    item = @order.line_items.where(product_id: params[:product_id]).last
    item.destroy!
    @order.set_total_price
    item_array = @order.items
    data = { order_id: @order.id, items: item_array, total_price: @order.price }
    render_success(data)
  rescue => e
    render_failure(e.message)
  end

  def edit_item
    pcs = params[:pcs].to_i
    raise "數量不能小於 0" if pcs < 0
    item = @order.line_items.where(product_id: params[:product_id]).last
    if pcs == 0
      item.destroy!
    else
      item.set_total_price(pcs)
    end
    @order.set_total_price
    item_array = @order.items
    data = { order_id: @order.id, items: item_array, total_price: @order.price }
    render_success(data)
  rescue => e
    render_failure(e.message)
  end

  def checkout
    @order.confirm_at = Time.current
    @order.save!
    @order.ready!
    # render_success({order_id: @order.id})
    redirect_to order_path(@order)
  end

  def index
    @orders = current_user.orders.where.not(status: 'cart')
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @products = Product.all
    # render json: { success: true, order: @order.as_json(include: [{ line_items: { include: :product } }]) }
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {})
    end
end
