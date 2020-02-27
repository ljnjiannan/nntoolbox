import VueRouter from 'vue-router'

const routes = [
  { path: '/',
    component: resolve => require(['@view/main'], resolve) ,
    redirect: '/home',
    children: [
      { path: 'home', component: resolve => require(['@view/home'], resolve) ,
        meta: {
          title: 'code-tools'
        },
      },
      { path: 'history', component: resolve => require(['@view/history'], resolve) ,
        meta: {
          title: 'code-tools'
        },
      },
      { path: 'project', component: resolve => require(['@view/projects'], resolve) ,
        meta: {
          title: 'code-tools'
        },
      },
    ]
  },
]

export default new VueRouter({
  routes
})