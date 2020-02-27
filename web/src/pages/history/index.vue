<template>
  <div style="display: flex;width: 100%;">
    <div style="width: 10rem;">
      <div 
        class="history-list-item"
        :class="item.path == currentPath? 'selected':''"
        v-for="(item, index) in list"
        :key="index"
        @click="selectItem(item.path)">
        {{ getNameFromPath(item.path) }}
      </div>
    </div>
    <ProjectContentView :path='currentPath' ref='projectContentView' />
  </div>
</template>

<script>
import ProjectContentView from '@/components/ProjectContentView'

export default {
  components: {
    ProjectContentView,
    // ProjectRunningView,
  },
  data() {
    return {
      list: [],
      currentPath: "",
      detail: {}
    }
  },
  created() {
    this.$jsb("getUserDefaultsDictionary",{key: 'user_default_history'}).then(res => {
      if (res) {
        this.list = res.map(item => {
          return {
            path: item.tag,
            script: item.script
          }
        })
        if (this.list.length) {
          this.currentPath = this.list[0].path
        }
      }
    })
  },
  methods: {
    selectItem(path) {
      this.currentPath = path
    }
  },
  // watch: {
  //   currentPath() {
  //     this.$refs.projectContentView.getData()
  //   }
  // }
}
</script>

<style lang='stylus' scoped>
.history-list-item {
  padding 10px;
}
.selected {
  background green;
}
</style>