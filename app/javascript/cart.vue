<template lang="pug">
  div
    template(v-for="cartItem in cartItems")
      .container
        .row
          .col-sm-5
            h3 {{ cartItem.product_name }}
          .col-sm-2
            select name="count"
              template(v-for="value in Array.from(new Array(100),(val,index)=>index)")
                option(:value="value" :selected="value == cartItem.pcs ? true : false") {{ value }}
          .col-sm-2
            button.btn.btn-primary(type="button") x
          .col-sm-3
            span {{ cartItem.total_price}}
</template>
<script>
import axios from 'axios';
export default {
  data: function () {
    return {
      cartMessage: "Hello cart!",
      products: [],
      cartItems: []
    }
  },

  methods: {
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
