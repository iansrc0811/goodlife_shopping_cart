import Vue from 'vue/dist/vue.esm'
import Order from '../order.vue'

document.addEventListener('DOMContentLoaded', () => {
  const el = "#orderVue"
  const order = new Vue({
    el,
    render: h => h(Order),
  })
})
