class CartController < ApplicationController
  	
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]

  def add_to_cart

  	@order = current_order
  		#lets add a message that will not allow our user to add '0' quantity

  		if params[:quantity].to_i == 0
      flash[:notice] = "Please enter a valid quantity to add to cart!"
      redirect_back(fallback_location: root_path) 
     

	    else 

	     #before we just add an item to our line_item table, lets check to see if that item is already there so we don't end up with duplicates.		

	     line_item = @order.line_items.where(product_id: params[:product_id].to_i).first
	     #An object is blank if it’s false, empty, or a whitespace string. For example, false, ”, ‘ ’, nil, 
	    #[], and {} are all blank.  So, if no records are returned, we will create a new record.
	    #Otherwise, we only update
	     	if line_item.blank?


			  	line_item = @order.line_items.new(product_id: params[:product_id], quantity: params[:quantity])

			  		@order.save
						line_item.update(line_item_total: line_item.quantity * line_item.product.price)



			  		session[:order_id]= @order.id
			  	
			  	redirect_back(fallback_location: root_path)


			  else
			  	#if the item is already in our line item table, we just want to update the quantity, not create a duplicate record


			  	new_quantity = line_item.quantity + params[:quantity].to_i
			  	line_item.update(quantity: new_quantity)	
			  	#once we update the quantity, we can update the line_item_total

			  	line_item.update(line_item_total: line_item.quantity * line_item.product.price)

			  redirect_back(fallback_location: root_path)	
		  
		  	end



  		end

 	end


  def view_order
  	@line_items = current_order.line_items

  end

  
  def checkout
  	# line_items = current_order.line_items
	  # @order = Order.create(user_id: current_user.id, subtotal: 0)

	  # line_items.each do |line_item|
	  #   line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
	  #   @order.order_items[line_item.product_id] = line_item.quantity 
	  #   @order.subtotal += line_item.line_item_total
	  # end
	  # @order.save

	  # @order.update(sales_tax: (@order.subtotal * 0.08))
	  # @order.update(grand_total: (@order.sales_tax + @order.subtotal))

	  # line_items.destroy_all

	  line_items = current_order.line_items

    if line_items.length != 0
        current_order.update(user_id: current_user.id, subtotal: 0)

		@order = current_order

		line_items.each do |line_item|
	  	    line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
	  	    @order.order_items[line_item.product_id] = line_item.quantity 
	  	    @order.subtotal += line_item.line_item_total
	  	end
		@order.save

	  	@order.update(sales_tax: (@order.subtotal * 0.08))
	  	@order.update(grand_total: (@order.sales_tax + @order.subtotal))

	        # @order.line_items.destroy_all

	        # session[:order_id] = nil
	    end
  end




  def edit_line_item
    
    line_item = LineItem.where(product_id: params[:product_id].to_i).first
    line_item.update(quantity: params[:quantity].to_i)
    line_item.update(line_item_total: line_item.quantity * line_item.product.price)

    redirect_back(fallback_location: view_order) 

  end 



  def delete_line_item
    line_item = LineItem.where(product_id: params[:product_id].to_i).first

    line_item.destroy
    redirect_back(fallback_location: view_order) 

  end  

  def order_complete
  	@order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i




    
    line_items = LineItem.where(order_id: params[:order_id])
    line_items.destroy_all

    @order.line_items.destroy_all

		session[:order_id] = nil
  	
    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    


  

  end	

end
