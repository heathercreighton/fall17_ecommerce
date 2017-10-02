class CartController < ApplicationController
  	
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]

  def add_to_cart
  		#lets add a message that will not allow our user to add '0' quantity

  		if params[:quantity].to_i == 0
      flash[:notice] = "Please enter a valid quantity to add to cart!"
      redirect_back(fallback_location: root_path) 
     

	    else 

	     #before we just add an item to our line_item table, lets check to see if that item is already there so we don't end up with duplicates.		

	     line_item = LineItem.where(product_id: params[:product_id].to_i).first
	     #An object is blank if it’s false, empty, or a whitespace string. For example, false, ”, ‘ ’, nil, 
	    #[], and {} are all blank.  So, if no records are returned, we will create a new record.
	    #Otherwise, we only update
	     	if line_item.blank?
			  	line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])

			  	line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

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
  	@line_items = LineItem.all
  end

  
  def checkout
  	line_items = LineItem.all
	  @order = Order.create(user_id: current_user.id, subtotal: 0)

	  line_items.each do |line_item|
	    line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
	    @order.order_items[line_item.product_id] = line_item.quantity 
	    @order.subtotal += line_item.line_item_total
	  end
	  @order.save

	  @order.update(sales_tax: (@order.subtotal * 0.08))
	  @order.update(grand_total: (@order.sales_tax + @order.subtotal))

	  line_items.destroy_all
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
end
