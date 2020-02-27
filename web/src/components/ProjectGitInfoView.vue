// 项目情况 包括git状态等
<template>
  <div style="width: 50%;overflow: scroll;">
    <el-collapse v-model="activeNames">
      <el-collapse-item title="分支信息" name="1" >
        <!-- 分支信息 -->
        <div class="project-git-info-header">当前分支</div>
        <div 
          style="margin-left: 10px;">
          <span>{{ currentBranch.branch.replace("* ","") }}</span>
          <div v-show="currentBranch.follow" style="font-size: .8rem;">
            <el-tag size="mini">跟踪到</el-tag> 
            <span style="color: gray;margin-left: 8px;">{{ currentBranch.follow }} </span>
          </div>
        </div>

        <div class="project-git-info-header">远程分支</div>
        <div 
          v-for="(subItem, index) in getGitBranchRemote" 
          :key="index"
          class="project-git-info-remote-item">
          <span>{{ subItem }}</span>
          <div>
            <el-button type="text" v-show="subItem != currentBranch.follow" @click="followBranch(subItem)" style="margin-left: 10px;">跟踪</el-button>
            <el-button type="text" @click="gitPull(subItem)">拉取</el-button>
          </div>
        </div>

        <div class="project-git-info-header">本地分支</div>
        <div 
          v-for="(subItem) in getGitBranchLocal" 
          :key="subItem"
          style="margin-left: 10px;">
          <span>{{ subItem }}</span>
        </div>

      </el-collapse-item>

      <el-collapse-item title="文件信息" name="2" >
        <span v-if="!isNeedAdd">无需要提交的文件</span>

        <div v-if="fileList && fileList.length" style="background: #e9eafa;padding: 8px;">
          <!-- <div class="project-git-info-header">文件列表</div> -->
          <file-list-view :files='fileList' @addFile="gitAddSingleFile">
          </file-list-view>
        </div>
        
        <button @click="gitAddAll" v-if="rakeFile.length" >全部添加</button>
        <div v-if="modifyFile.length">
          <el-input v-model="commitInfo" placeholder="请输入内容"></el-input>
          <button @click="gitCommit">提交</button>
        </div>
        <button 
          v-show="followBranchInfo.length > 1 && followBranchInfo[0] == 'ahead'" 
          @click="gitPush"  >
          推送
        </button>

      </el-collapse-item>
    </el-collapse>

  </div>
</template>

<script>
import FileListView from './FileListView'
export default {
  components: {
    FileListView
  },
  props: {
    path: String
  },
  data() {
    return {
      gitInfo: {},
      commitInfo: '',
      activeNames: ["1","2","3"],
      newFile:[],
      modifyFile: [],
      deleteFile: [],
      rakeFile: {},
      fileList: {}
    }
  },
  computed: {
    // 分支信息
    branchInfo() {
      if (this.gitInfo.info)
        return JSON.parse(this.gitInfo.info)
      return {}
    },
    // 当前分支
    currentBranch() {
      if (this.branchInfo.current) {
        return JSON.parse(this.branchInfo.current)
      }
      return { branch: ""}
    },
    // 跟踪分支的信息
    followBranchInfo() {
      if (this.currentBranch.info && this.currentBranch.info.trim().split(" ").length > 1) {
        return this.currentBranch.info.trim().split(" ")
      } 
      return []
    },
    // 远程分支
    getGitBranchRemote() {
      if (this.gitInfo.info) {
        let jsonInfo = JSON.parse(this.gitInfo.info)
        if (jsonInfo.remote)
          return jsonInfo.remote
      } 
      return []
    },
    // 本地分支
    getGitBranchLocal() {
      if (this.gitInfo.info) {
        let jsonInfo = JSON.parse(this.gitInfo.info)
        if (jsonInfo.locals)
          return jsonInfo.locals
      }
      return []
    },
    isNeedAdd() {
      return this.newFile.length || 
        this.modifyFile.length || 
        this.deleteFile.length ||
        this.rakeFile
    },
  },
  methods: {
    getData(item) {
      var path = this.path
      if (item)  {
        path = item
      }
      this.$jsb("getGitInfo", {path: path})
        .then(res => {
          this.gitInfo = res
          if (res.status) {
            let branchStatus = JSON.parse(res.status)
            this.newFile = branchStatus.newFile
            this.modifyFile = branchStatus.modifyFile
            this.deleteFile = branchStatus.deleteFile
            this.rakeFile = branchStatus.rakeFile? this.getFileList(branchStatus.rakeFile):null
            this.fileList = this.getGitFileList(res.statusList.map(item => JSON.parse(item)))
          }
        })
    },
    followBranch(item) {
      let current = this.currentBranch.branch
      this.gitScript(`git branch --set-upstream-to ${item} ${current.replace("* ","")}`)
    },
    gitAddAll() {
      this.gitScript("git add .")
    },
    gitCommit() {
      this.gitScript(`git commit -m ${this.commitInfo}`)
    },
    gitAddSingleFile(file) {
      this.gitScript(`git add ${file}`)
    },
    gitPush() {
      var remotes = this.currentBranch.follow.trim().split("/")
      var remoteInfo = ''
      if (remotes.length > 1) {
        remoteInfo = `${remotes[0]} ${remotes[1]}`
      }
      this.gitScript(`git push ${remoteInfo}`)
    },
    gitPull(item) {
      var remotes = item.trim().split("/")
      var remoteInfo = ''
      if (remotes.length > 1) {
        remoteInfo = `${remotes[0]} ${remotes[1]}`
      }
      this.gitScript(`git pull ${remoteInfo}`)
    },
    getGitFileList(list) {
      var fileMap = {}
      for (var i in list) {
        this.getGitSubFolder(fileMap,"", list[i])
      }
      return fileMap;
    },
    getGitSubFolder(folder,preName, file) {
      var filePath = file.path
      filePath = filePath.substr(preName.length, filePath.length - preName.length)
      var paths = filePath.split("/")
      
      if (paths.length > 1) {
        if (!folder[paths[0]]) {
          folder[paths[0]] = {
            list: []
          }
        }
        var nextFolder = folder[paths[0]]
        var nextPrefName = preName + "\\" + paths[0]
        this.getGitSubFolder(nextFolder, nextPrefName, file)
      } else if (paths.length == 1) {
        folder.list.push(file)
      }
    },
    getFileList(list) {
      var fileMap = {}
      for (var i in list) {
        this.getSubFolder(fileMap, list[i])
      }
      // this.getSubFolder(fileMap, list[1])
      return fileMap;
    },
    getSubFolder(folder, file) {
      var paths = file.split("/")
      if (paths.length > 1) {
        if (!folder[paths[0]]) {
          folder[paths[0]] = {
            list: []
          }
        }
        this.getSubFolder(folder[paths[0]],file.substr(paths[0].length+1,file.length - paths[0].length))
      } else if (paths.length == 1) {
        folder.list.push(paths[0])
      }
    },
    gitScript(script) {
      this.$jsb("runGitScript",{path: this.path,script})
        .then(() => {
          this.getData()
        })
    }
  },
}
</script>

<style lang='stylus' scoped>

.project-git-info-header {
  width: 4rem;
  border-bottom 1px solid #dfdfdf
  font-size: .8rem
  color: #3c3c3c;
  margin-top: 10px;
  margin-bottom: 4px;
}
.project-git-info-remote-item {
  display: flex;
  justify-content space-between;
  align-items center;
  margin-left: 10px;
}
</style>