// import Vue from 'vue'
// import App from '../todolists.vue'

// document.addEventListener('DOMContentLoaded', () => {
//   const el = "#todolists"
//   const app = new Vue({
//     el,
//     render: h => h(App)
//   })

//   console.log(app)
// })


import Vue from 'vue/dist/vue.esm'
import App from '../app.vue'
import Cart from '../cart.vue'


document.addEventListener('DOMContentLoaded', () => {
  const el = "#cart"
  const cart = new Vue({
    el,
    render: h => h(Cart)
  })
})
