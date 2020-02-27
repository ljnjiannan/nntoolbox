import Vue from 'vue'
import VueRouter from 'vue-router'
import router from './router'
import App from './App.vue'
import Loader from './jsloader'
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

Vue.config.productionTip = false
Vue.use(Loader)
Vue.use(ElementUI)
Vue.use(VueRouter)
new Vue({
  render: h => h(App),
  router
}).$mount('#app')
