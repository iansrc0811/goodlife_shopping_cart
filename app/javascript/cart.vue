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
              template(v-for="cartItem in cartItems")
                .container
                  .row
                    .col-sm-5
                      h3 {{ cartItem.product_name }}
                    .col-sm-2
                      input(type="number" v-model:value="cartItem.pcs" style="width: 60px")
                      //- select name="count"
                      //-   template(v-for="value in Array.from(new Array(100),(val,index)=>index)")
                      //-     option(:value="value" :selected="value == cartItem.pcs ? true : false") {{ value }}
                    .col-sm-2
                      button.btn.btn-danger(type="button") x
                    .col-sm-3
                      //- span {{ cartItem.pcs * cartItem.pcs_price }}
                      span {{ getTotalPrice(cartItem.product_id) }}
                hr
            div#subtotal
              | Subtotal: "{{ totalPrice() }}"
          .modal-footer
            button.btn.btn-secondary(data-dismiss="modal" type="button")
              | Close
            button.btn.btn-primary(type="button")
              | Save changes
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
                  //- select(:id="'add-to-cart-counter-' + product.id" name="count")
                  //-   template(v-for="value in Array.from(new Array(20),(val,index)=>index+1)")
                  //-     option(:value="value") {{ value }}
                .col-sm-8
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
      cartItems: []
    }
  },
  computed: {

  },
  methods: {
     getTotalPrice: function(productId) {
      let item = this.cartItems.find(item => {
        return item.product_id == productId
      })
      // return
      let lineItemTotalPrice = Number(item.pcs) * Number(item.pcs_price)
      item.total_price = lineItemTotalPrice
      return lineItemTotalPrice
    },
    getCart: function() {
      axios({
        methods: 'get',
        url: '/orders/get_cart'
      })
      .then((response) => {
        this.cartItems = response.data.items
      });
    },
    getProducts: function() {
      axios({
        methods: 'get',
        url: '/products.json'
      })
      .then((response) => {
        // console.log(response)
        this.products = response.data
      });
    },
    addToCart: function(productId) {
      // let productId = $("button[id='add-to-cart-btn-3']").data('product')
      let productPcs = $("#add-to-cart-counter-" + productId).val()
      axios.post('/products/' + productId + '/add_to_cart', {
        pcs: productPcs
      })
      .then(response => {
        let cartItem = this.cartItems.find(item => {
          return item.product_id == productId
        })
        cartItem.pcs = Number(cartItem.pcs) + Number(productPcs)
        cartItem.total_price = Number(cartItem.pcs) * Number(cartItem.pcs_price)
        // console.log(response)
        // this.products = response.data
      })
      .catch(error => {

      });
    },
    totalPrice: function() {
      console.log('totalPrice: ' + this.cartItems.map(item => item.total_price))
      return this.cartItems.map(item => item.total_price).reduce((prev, next) => prev + next, 0);
    }
  },
  mounted: function() {
    this.getCart()
    this.getProducts()

  },
  destroyed: function() {
    console.log('destroyed')
  }
}
</script>
