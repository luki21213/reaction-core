###
# Cart
#
# methods to return cart calculated values
# cartCount, cartSubTotal, cartShipping, cartTaxes, cartTotal
# are calculated by a transformation on the collection
# and are available to use in template as cart.xxx
# in template: {{cart.cartCount}}
# in code: ReactionCore.Collections.Cart.findOne().cartTotal()
###
ReactionCore.Collections.Cart = Cart = @Cart = new Mongo.Collection "Cart",
  transform: (cart) ->
    cart.cartCount = ->
      count = 0
      ((count += items.quantity) for items in cart.items) if cart?.items
      return count

    cart.cartShipping = ->
      shipping = 0
      if cart?.shipping?.shipmentMethod?.rate
        shipping = cart?.shipping?.shipmentMethod?.rate
      else ((shipping += shippingMethod.rate) for shippingMethod in cart.shipping.shipmentMethod) if cart?.shipping?.shipmentMethod.length > 0
      return shipping

    cart.cartSubTotal = ->
      subtotal = 0
      ((subtotal += (items.quantity * items.variants.price)) for items in cart.items) if cart?.items
      subtotal = subtotal.toFixed(2)
      return subtotal

    cart.cartTaxes = ->
      ###
      # TODO: lookup cart taxes, and apply rules here
      ###
      return "0.00"

    cart.cartDiscounts = ->
      ###
      # TODO: lookup discounts, and apply rules here
      ###
      return "0.00"

    cart.cartTotal = ->
      subtotal = 0
      ((subtotal += (items.quantity * items.variants.price)) for items in cart.items) if cart?.items
      shipping = 0
      if cart?.shipping?.shipmentMethod?.rate
        shipping = cart?.shipping?.shipmentMethod?.rate
      else ((shipping += shippingMethod.rate) for shippingMethod in cart.shipping.shipmentMethod) if cart?.shipping?.shipmentMethod.length > 0
      shipping = parseFloat shipping
      subtotal = (subtotal + shipping) unless isNaN(shipping)
      total = subtotal.toFixed(2)
      return total
    return cart

ReactionCore.Collections.Cart.attachSchema ReactionCore.Schemas.Cart

# Accounts
ReactionCore.Collections.Accounts = Accounts = @Accounts = new Mongo.Collection "Accounts"
ReactionCore.Collections.Accounts.attachSchema ReactionCore.Schemas.Accounts

# Orders
ReactionCore.Collections.Orders = Orders = @Orders = new Mongo.Collection "Orders",
  transform: (order) ->
    order.itemCount = ->
      count = 0
      ((count += items.quantity) for items in order.items) if order?.items
      return count
    return order

ReactionCore.Collections.Orders.attachSchema [ReactionCore.Schemas.Cart, ReactionCore.Schemas.Order, ReactionCore.Schemas.OrderItems]

# Packages
ReactionCore.Collections.Packages = new Mongo.Collection "Packages"
ReactionCore.Collections.Packages.attachSchema ReactionCore.Schemas.PackageConfig

# Products
ReactionCore.Collections.Products = Products = @Products = new Mongo.Collection "Products"
ReactionCore.Collections.Products.attachSchema ReactionCore.Schemas.Product

# Shipping
ReactionCore.Collections.Shipping = new Mongo.Collection "Shipping"
ReactionCore.Collections.Shipping.attachSchema ReactionCore.Schemas.Shipping

# Taxes
ReactionCore.Collections.Taxes = new Mongo.Collection "Taxes"
ReactionCore.Collections.Taxes.attachSchema ReactionCore.Schemas.Taxes

# Discounts
ReactionCore.Collections.Discounts = new Mongo.Collection "Discounts"
ReactionCore.Collections.Discounts.attachSchema ReactionCore.Schemas.Discounts

# Shops
ReactionCore.Collections.Shops = Shops = @Shops = new Mongo.Collection "Shops",
  transform: (shop) ->
    for index, member of shop.members
      member.index = index
      member.user = Meteor.users.findOne member.userId
    return shop

ReactionCore.Collections.Shops.attachSchema ReactionCore.Schemas.Shop

# Tags
ReactionCore.Collections.Tags = Tags = @Tags = new Mongo.Collection "Tags"
ReactionCore.Collections.Tags.attachSchema ReactionCore.Schemas.Tag
