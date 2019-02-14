<template lang="pug">
  .orderVue
    h2
      | Order Number: {{ orderName}}
    table.table.table-striped
      thead
        tr
          th
            | #
          th(scope="col")
            | Product Name
          th(scope="col")
            | Price
          th(scope="col")
            | Pcs
          th(scope="col")
            | Product Total Price
          th(scope="col")
            | Order Total Price
          button.btn.btn-primary(scope="col" @click="setEditMode()") edit
      tbody
        template(v-for="(item, index) in lineItems")
          tr
            th(scope="row") {{ index+1 }}
            td(scope="row") {{ item.product_name }}
            td(scope="row") {{ item.pcs_price }}
            td(scope="row") {{ item.pcs }}
            td(scope="row") {{ item.total_price }}
            td(scope="row") -
            td
        tr
          th(scope="row") -
          td(scope="row") -
          td(scope="row") -
          td(scope="row") -
          td(scope="row") -
          td(scope="row") {{ orderTotalPrice }}
          td(scope="row")
</template>
<script>
import axios from 'axios';
axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
export default {
  data: function () {
    return {
      products: [],
      lineItems: [],
      orderTotalPrice: null,
      orderId: null,
      orderName: null
    }
  },
  computed: {

  },
  methods: {
    setEditMode: function() {

    },
    getLineItem: function() {
      let urlSplitArray = window.location.href.split('/')
      let urlOrderId = urlSplitArray[urlSplitArray.length -1]
      console.log('getLineItem: ' + urlOrderId)
      axios.get('/orders/get_line_items', {
      params: {
        order_id: urlOrderId
        }
      })
      .then((response) => {
        this.lineItems = response.data.items
        this.orderTotalPrice = response.data.total_price
        this.orderId = urlOrderId
        this.orderName = response.data.order_name
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
      axios.post('/orders/' + this.orderId + '/edit_item', {
        product_id: cartItem.product_id,
        pcs: cartItem.pcs
      }).then(response => {
        this.cartItems = response.data.items
      })
      .catch(error => {

      })
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
    this.getLineItem()
    // this.getProducts()
  },
}
</script>
