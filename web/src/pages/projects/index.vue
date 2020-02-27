<template>
  <div style="width: 100%;">
    <!-- 目录导航 -->
    <div style="display: flex;justify-content: space-between;">
      <FilePathNavigator :paths="getPathList" @pathClick="changeDirectory"/>
    </div>
    <div style="display:flex;height: calc(100% - 3rem - 20px);width: 100%;">
      <!-- 文件目录 -->
      <FolderListView :list="list" @dirClick="changeDirectory"/>
      <!-- 目录详情 -->
      <ProjectContentView :path='path'/>
      <!-- 项目运行详情 -->
      <!-- <ProjectRunningView v-show="scriptList.length" :scriptList='scriptList' /> -->
      
    </div>
  </div>
</template>

<script>

import FilePathNavigator from './FilePathNavigator'
import FolderListView from '@/components/FolderListView'
import ProjectContentView from '@/components/ProjectContentView'
// import ProjectRunningView from '@/components/ProjectRunningView'

export default {
  components: {
    FilePathNavigator,
    FolderListView,
    ProjectContentView,
    // ProjectRunningView,
  },
  data() {
    return {
      path: '',
      list: [],
      detail: {},
      scriptList: [],
      projectInfoIndex: 0,
      gitInfo: {},
      testLog: "> palm-hospital-vue@0.1.0 serve /Users/jiannanliu/Project/palm-hospital-vue > vue-cli-service serve </br> INFO Starting development server... </br> DONE Compiled successfully in 8231ms3:29:55 PM </br> </br> App running at: </br> - Local: http://localhost:9099/ </br> - Network: http://192.168.30.188:9099/ </br> </br> Note that the development build is not optimized. </br> To create a production build, run yarn build. </br>"
    }
  },
  computed: {
    getPathList () {
      if (this.list.length) {
        var paths = this.path.split("/")
        var list = []
        for (var i in paths) {
          if (list.length ==0) {
            list.push({
              name: paths[i] || "/",
              path: "" + paths[i]  
            })
          } else {
            list.push({
              name: paths[i],
              path: list[i-1].path + "/" + paths[i]
            })
          }
          
        }
        return list
      } else {
        return []
      }
    },
  },
  mounted() {
    if (this.$route.query && this.$route.query.path) {
      this.path = this.$route.query.path
    }
    if (!this.path) {
      this.$jsb("initDirectory",{path: this.path})
        .then(res => {
          this.path = res
          this.getDirectorys()
        })
    }
    if (this.$route.params && this.path)  {
      this.getDirectorys()
    } 
  },
  methods: {
    getDirectorys() {
      this.$jsb("getDirectorys",{path: this.path})
        .then(res => {
          this.list = res.list
        })
    },
    changeDirectory(item) {
      this.path = item.path
      this.getDirectorys()
    },
  }
}
</script>

<style>

</style>