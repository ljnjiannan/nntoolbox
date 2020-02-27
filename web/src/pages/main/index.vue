<template>
  <div style="display: flex;">
    <MainTabView />
    <router-view style="height: 100%;"></router-view>
  </div>
</template>

<script>
import MainTabView from '@view/main/MainTabView.vue'

export default {
  components: {
    MainTabView,
  },
  created () {
    var list = [
      "src/components/FilePathNavigator.vue",
      "src/components/FolderListView.vue",
      "src/components/PorjectNodejsInfo.vue",
      "src/components/ProjectContentView.vue",
      "src/components/ProjectGitInfoView.vue",
      "src/pages/history/index.vue",
      "src/pages/main/index.vue",
      "src/pages/projects/index.vue",
    ]
    var folder = {}
    for (var i in list) {
      this.getSubFolder(folder, list[i])
    }
    // console.log(folder)
  },
  methods: {
    getSubFolder(folder, file) {
      var paths = file.split("/")
      if (paths.length > 1) {
        if (paths.length == 2 && !folder[paths[0]] ) {
          folder[paths[0]] = []
        } else if (!folder[paths[0]]) {
          folder[paths[0]] = {}
        }
        this.getSubFolder(folder[paths[0]],file.substr(paths[0].length+1,file.length - paths[0].length))
      } else if (paths.length == 1) {
        folder.push(paths[0])
      }
    },
  }
}
</script>

