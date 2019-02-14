<template lang="pug">
  .cartVue
    #cartModal.modal.fade(aria-hidden="true" aria-labelledby="exampleModalCenterTitle" role="dialog" tabindex="-1")
      .modal-dialog.modal-dialog-centered(role="document")
        .modal-content
          .modal-header
            h5#exampleModalLongTitle.modal-title
              | Shopping Cart
            button.close(aria-label="Close" data-dismiss="modal" type="button")
              span(aria-hidden="true")
                | &times;
          .modal-body
            div#modalBodyBorder
              template(v-if="cartItems.length === 0")
                h3 The Shpoping Cart Is Empty
              template(v-else)
                template(v-for="cartItem in cartItems")
                  .container
                    .row
                      .col-sm-5
                        h3 {{ cartItem.product_name }}
                      .col-sm-2
                        select(v-model="cartItem.pcs" @change="editCartItemNumber(cartItem)")
                          template(v-for="value in Array.from(new Array(100),(val,index)=>index+1)")
                            option(:value="value" :selected="value == cartItem.pcs ? true : false") {{ value }}
                      .col-sm-2
                        button.btn.btn-danger(type="button" @click="removeItem(cartItem.product_id)") x
                      .col-sm-3
                        span {{ getTotalPrice(cartItem.product_id) }}
                hr
            div#subtotal
              | Subtotal: "{{ totalPrice() }}"
          .modal-footer
            button.btn.btn-secondary(data-dismiss="modal" type="button")
              | Close
            button.btn.btn-primary(type="button" @click="checkoutOrder()" :disabled="disabledCheckout")
              | Proced to checkout
    .card-deck
      template(v-for="product in products")
        .col-md-4
          .card
            .card-body
              h5.card-title
              p.card-text {{ product.name }}
            .card-footer
              .row
                .col-sm-4
                  input(type="number" name="productCount" style="width: 60px" value=1 :id="'add-to-cart-counter-' + product.id")
                .col-sm-3
                  | Price: {{ product.price }}
                .col-sm-5
                  button.btn.btn-primary(:id="'add-to-cart-btn-' + product.id" :data-product="product.id" type="button" data-target="#cartModal" data-toggle="modal" @click="addToCart(product.id)")
                    | Add to cart

</template>
<script>
import axios from 'axios';
axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
export default {
  data: function () {
    return {
      cartMessage: "Hello cart!",
      products: [],
      cartItems: [],
      orderId: null
    }
  },
  computed: {
    disabledCheckout: function() {
      return this.cartItems.length === 0 || this.cartItems.some(item => item.pcs === '' || item.pcs <= 0)
    },
  },
  methods: {
    getTotalPrice: function(productId) {
      let item = this.cartItems.find(item => {
        return item.product_id == productId
      })
      let lineItemTotalPrice = Number(item.pcs) * Number(item.pcs_price)
      item.total_price = lineItemTotalPrice
      return lineItemTotalPrice
    },
    getCart: function() {
      axios({
        methods: 'get',
        url: '/orders/get_line_items'
      })
      .then((response) => {
        this.cartItems = response.data.items
        this.orderId = response.data.order_id
      });
    },
    getProducts: function() {
      axios({
        methods: 'get',
        url: '/products.json'
      })
      .then((response) => {
        this.products = response.data
      });
    },
    addToCart: function(productId) {
      let productPcs = $("#add-to-cart-counter-" + productId).val()
      axios.post('/products/' + productId + '/add_to_cart', {
        pcs: productPcs
      })
      .then(response => {
        let cartItem = this.cartItems.find(item => {
          return item.product_id == productId
        })
        if (cartItem !== undefined) {
          cartItem.pcs = Number(cartItem.pcs) + Number(productPcs)
          cartItem.total_price = Number(cartItem.pcs) * Number(cartItem.pcs_price)
        } else {
          let product = this.products.find(product => product.id == productId)
          this.cartItems.push(
            {
              pcs: productPcs,
              pcs_price: product.price,
              product_id: product.id,
              product_name: product.name,
              total_price: product.price * productPcs
            }
          )
        }
        // console.log(response)
        // this.products = response.data
      })
      .catch(error => {
      });
    },
    removeItem: function(productId) {
      axios.post('/orders/' + this.orderId + '/remove_item', {
        product_id: productId
      }).then(response => {
        this.cartItems = response.data.items
      })
      .catch(error => {

      })
    },
    editCartItemNumber: function(cartItem) {
      // console.log(typeof(cartItem.pcs))
      if (cartItem.pcs === '') {
        cartItem.pcs = 0
      } else {
        axios.post('/orders/' + this.orderId + '/edit_item', {
          product_id: cartItem.product_id,
          pcs: cartItem.pcs
        }).then(response => {
          this.cartItems = response.data.items
        })
        .catch(error => {

        })
      }
    },
    checkoutOrder: function() {
       axios.post('/orders/' + this.orderId + '/checkout', {
      }).then(response => {
        window.location.href = '/orders/' + this.orderId
      })
      .catch(error => {

      })
    },
    totalPrice: function() {
      if (this.cartItems.length > 0) {
        return this.cartItems.map(item => item.total_price).reduce((prev, next) => prev + next, 0);
      } else {
        return 0
      }
    }
  },
  mounted: function() {
    this.getCart()
    this.getProducts()
  },
}
</script>
