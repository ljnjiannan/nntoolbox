<template>
  <div style="width: calc(100% - 20rem);display: flex;">
    <div style="margin: 10px 1rem;width: 15rem;overflow-x: scroll;">
      <!-- <h1>{{ getNameFromPath(detail.path)}}</h1> -->
      
      <div style="margin: 1rem 0;font-size: .88rem;">
        <div>创建时间: {{ detail.createDate }}</div>
        <div>修改时间: {{ detail.modifyDate }}</div>
        <!-- <div >文件大小: {{ detail.size }}</div> -->
        <!-- <div>{{ detail }}</div> -->
      </div>
      <div>
        <el-button style="width: 10rem;" @click="openInFinder" round>在Finder中打开</el-button>
        <el-button style="width: 10rem;margin: 1rem 0 0 0" @click="openInTerminal" round>在终端中打开</el-button>
        <el-button style="width: 10rem;margin: 1rem 0 0 0" @click="openInIde" round>在IDE中打开</el-button>
      </div>
      <div class="project-content-info-list">
        <div 
          v-for="item in infoList"
          :key="item.id"
          :class="activeNames == item.id? 'selected':''" v-show="item.show" @click="selectInfoItem(item.id)" >
          <span>{{ item.title }}</span>
          <i class="el-icon-arrow-right"></i>
        </div>

      </div>

    </div>
    <!-- git相关信息 -->
    <ProjectGitInfoView 
      ref="projectGitView"
      v-show="activeNames == 1" 
      :path="path"
      />
    
    <PorjectNodejsInfo 
      ref="projectNodejsView"
      v-show="activeNames == 2"
      :path="path"/>
  </div>
</template>

<script>
import PorjectNodejsInfo from '@/components/PorjectNodejsInfo'
import ProjectGitInfoView from './ProjectGitInfoView'

export default {
  components: {
    ProjectGitInfoView,
    PorjectNodejsInfo
  },
  props: {
    path: String,
  },
  data() {
    return {
      gitInfo: {},
      activeNames: 0,
      detail: {},
      infoList: [
        { id: 1, show: false, title: 'git 信息'},
        { id: 2, show: false, title: 'nodejs 信息'},
      ]
    }
  },
  computed: {
    getDetail() {
      let detail = this.detail.nodejs
      if (detail) {
        return {
          ...JSON.parse(detail)
        }
      } else {
        return {}
      }
    },
  },
  created() {

  },
  methods: {
    getData() {
      if (this.path == "") return
      this.$jsb("getDirectoryDetail", {path: this.path})
        .then(detail => {
          this.detail = detail
          this.activeNames = 0
          if (this.detail.isGit) {
            this.selectInfoItem(1)
          }
          this.infoList[0].show = this.detail.isGit
          this.infoList[1].show = this.detail.isNodejs
          // this.selectInfoItem(this.activeNames)
        })
    },
    selectInfoItem(item) {
      if (item == this.activeNames) {
        return
      }
      this.activeNames = item
      if (item == 1) {
        this.$refs.projectGitView.getData(this.path)
      } else if (item == 2) {
        this.$refs.projectNodejsView.getData()
      }
    },
    openInFinder() {
      this.$jsb("openFile",{path: this.path})
    },
    openInTerminal() {
      this.$jsb("getSettingData",{path: ""})
        .then(res => {
          const data = JSON.parse(res)
          if (data.terminalPath) {
            this.$jsb("openFile",{path: this.path, app: data.terminalPath})
          } else {
            this.$jsb("openFile",{path: this.path, app: 'Terminal'})
          }
        })
    },
    openInIde() {
      this.$jsb("getSettingData",{path: ""})
        .then(res => {
          const data = JSON.parse(res)
          if (data.idePath) {
            this.$jsb("openFile",{path: this.path, app: data.idePath})
          } else {
            this.$message({
              message: '请先设置常用IDE',
              type: 'warning'
            });
            this.$jsb("showSettingView",{})
          }
        })
    }
  },
  watch: {
    path() {
      this.getData()
    }
  }
}
</script>

<style lang="stylus" scoped>
.project-content-info-list {
  color black;
  line-height 2rem;
  font-size .88rem;
  border-top 1px solid #e9ecfc;
  margin-top 2rem;
  div {
    padding 10px;
    border-bottom 1px solid #e9ecfc;
    display flex;
    align-items center;
    justify-content space-between;
  }
  i {
    color white;
  }
}

.selected {
  background #6373fc;
  color white;
}
</style>