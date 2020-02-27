<template>
  <div>
    <el-dialog
      title="设置"
      :visible.sync="dialogVisible"
      :before-close="handleClose"
      width="60%">
      <div class="setting-view-item">
        <div style="width: 5rem;">文件目录</div>
        <el-input v-model="rootPath" disabled="">
          <el-button @click="changeRootDirectory" slot="append">浏览</el-button>
        </el-input>
      </div>
      <div class="setting-view-item">
        <div style="width: 5rem;">IDE应用</div>
        <el-input v-model="idePath" disabled="">
          <el-button @click="changeIdePath" slot="append">浏览</el-button>
        </el-input>
      </div>
      <div class="setting-view-item">
        <div style="width: 5rem;">终端应用</div>
        <el-input v-model="terminalPath" disabled="">
          <el-button @click="changeTerminalPath" slot="append">浏览</el-button>
        </el-input>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">关 闭</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  data() {
    return {
      dialogVisible: false,
      rootPath: '',
      idePath: '',
      terminalPath: '',
      settingChanged: false
    }
  },
  created() {
    // if (!this.path) {

    // }
    window.onSettingChanged = (res) => {
      if (res.rootPath) {
        this.rootPath = res.rootPath
      }
      if (res.idePath) {
        this.idePath = res.idePath
      }
      if (res.terminalPath) {
        this.terminalPath = res.terminalPath
      }
      this.settingChanged = true
    }
    window.showSettingView = () => {
      this.$jsb("getSettingData",{path: ""})
        .then(res => {
          const data = JSON.parse(res)
          this.rootPath = data.rootPath
          this.idePath = data.idePath
          this.terminalPath = data.terminalPath
        })
      this.dialogVisible = true
    }
  },
  methods: {
    changeRootDirectory() {
      this.$jsb("chooseDirectory",{path: "", type: 'root'})
    },
    changeIdePath() {
      this.$jsb("chooseDirectory",{path: "", type: 'ide'})
    },
    changeTerminalPath() {
      this.$jsb("chooseDirectory",{path: "", type: 'terminal'})
    },
    handleClose(done) {
      done()
      if (this.settingChanged) {
        document.location.reload()
      }
    },
  }
}
</script>

<style lang="stylus" scoped>
.setting-view-item 
  width 80%
  display flex
  align-items center
  margin-top 10px
    
  input
    width 100%
    margin-left 1rem
</style>
