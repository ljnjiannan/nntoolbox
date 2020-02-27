<template>
  <div class="main-tab-view">
    <div>
      <div v-for="item in tabs" :key="item.id"
        style="cursor: pointer;"
        @click="itemClick(item)"
        :class="currentTab == item.id? 'main-tab-item-selected':''">
        {{ item.title }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      currentTab: 0,
      tabs: [
        { id: 0, title: '项目概览', path: '/home'},
        // { id: 1, title: '项目历史', path: '/history'},
        { id: 2, title: '目录浏览', path: '/project'},
      ]
    }
  },
  methods: {
    itemClick(item) {
      this.currentTab = item.id
      this.$router.replace({
        path: item.path
      })
    }
  },
  watch: {
    '$route.path' (path) {
      if (path == '/home') {
        this.currentTab = 0
      } else if (path == '/project') {
        this.currentTab = 2
      }
    }
  }
}
</script>

<style lang='stylus' scoped>
.main-tab-view {
  padding 8px;
  display flex;
  align-items center;
  background #7e80e6;
  height 100%;
  width 6rem;
  color white;
  
  div {
    text-align center;
    width 100%;
    line-height 2rem;
    margin 2rem 0;
    font-size .75rem;
    color #bbbbf2;
  }
}

.main-tab-item-selected {
  color white !important;
  border-right 2px solid white;
}

</style>