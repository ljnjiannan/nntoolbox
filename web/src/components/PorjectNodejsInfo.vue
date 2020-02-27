<template>
  <div style="width: calc(100% - 15rem);overflow: scroll;">
    <el-collapse v-model="activeNames">
      <el-collapse-item title="script" name="1">
        <div class="project-nodejs-info-dependence-item" v-for="(item, index) in scriptList" :key="index" >
          <div>
            <div style="font-size: 1rem;color: black;">{{ item.command }}</div>
            <div style="font-size: .8rem;color: gray;">{{ item.script }}</div>
            
          </div>
          <el-button style="padding: 8px 16px;" round v-if="!item.running" @click="runScript(item)">运行</el-button>
          <el-button style="padding: 8px 16px;" round v-if="item.running" @click="terminateScript(item)">停止</el-button>
        </div>
      </el-collapse-item>
      <el-collapse-item title="dependencies" name="2" >
        <div class="project-nodejs-info-dependence-item" v-for="(item, index) in dependenciesList" :key="index" >
          <div style="font-size: 1rem;color: black;">{{ item.title }}</div>
          <div style="font-size: .8rem;color: gray;">{{ item.version }}</div>
        </div>
      </el-collapse-item>
      <el-collapse-item title="devDependencies" name="3">
        <div class="project-nodejs-info-dependence-item" v-for="(item, index) in devDependenciesList" :key="index" >
          <div style="font-size: 1rem;color: black;">{{ item.title }}</div>
          <div style="font-size: .8rem;color: gray;">{{ item.version }}</div>
        </div>
      </el-collapse-item>
      <el-collapse-item title="日志" name="4">
        <pre>
          <div v-html="getLogs"></div>
        </pre>
      </el-collapse-item>
    </el-collapse>

  </div>
</template>

<script>
export default {
  props: {
    path: String
  },
  data() {
    return {
      log: '',
      info: {},
      activeNames: ["1","2","3"],
    }
  },
  computed: {
    dependenciesList() {
      if (this.info.devDependence) {
        return this.info.dependence.map(item => {
          let content = item.split(":")
          return {
            title: content[0],
            version: content[1]
          }
        })
      }
      return []
    },
    devDependenciesList() {
      if (this.info.devDependence) {
        return this.info.devDependence.map(item => {
          let content = item.split(":")
          return {
            title: content[0],
            version: content[1]
          }
        })
      }
      return []
    },
    scriptList() {
      if (this.info.runConmands) {
        return this.info.runConmands.map(item => {
          return JSON.parse(item)
        }).sort((a,b) => {
          return a.command[0] - b.command[0]
        })
      }
      return []
    },
    getLogs() {
      var lines = this.log.split("\n").map(item => {
        var reg = /http.+\//g.exec(item)
        return item.replace(reg, `<a href='${reg}' style='color:blue;'>${reg}</a>`)
      })
      return lines.join("\n")
    }
  },
  methods: {
    getData() {
      if (!this.path) return
      this.$jsb("getNodejsInfo", {path: this.path})
        .then(detail => {
          this.info = JSON.parse(detail)
          var commands = this.info.runConmands
          var itemRunning = false
          for (var i in commands) {
            const command = JSON.parse(commands[i])
            if (command.running ) {
              this.log = command.log
              itemRunning = true
            }
          }
          if (!itemRunning) {
            this.log = ""
          }
        })
    },
    runScript(item) {
      this.$jsb("runNodejsScript",{
        path: this.path,
        script: `cd ${this.path.replace(" ","\\ ")} && npm run ${item.command}`,
        command: item.command
      }).then(res => {
        this.info = JSON.parse(res)
      })
    },
    terminateScript(item) {
      this.$jsb("terminateScript",{
        path: this.path,
        command: item.command
      }).then(res => {
        this.info = JSON.parse(res)
      })
    }
  },
  created() {
    this.$bindSwift("updateLog",res => {
      if (!res) {
        return
      }
      var list = JSON.parse(res)
      for (var i in list) {
        var item = JSON.parse(list[i])
        if (this.path == item.name) {
          this.log = item.log
        }
      }
    })
  }
}
</script>

<style lang="stylus" scoped>
.project-nodejs-info-dependence-item {
  display flex;
  justify-content space-between;
  padding: 0 1rem 0 8px;
  line-height 2.5rem;
  border-bottom 1px solid #efefef;
  align-items center;
}
</style>
