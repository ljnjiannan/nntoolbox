<template>
  <div style="overflow: scroll;padding-bottom: 2rem;">
    <div style="font-weight: 600;margin: 10px;">
      正在运行 {{ runningList.length }}个
    </div>
    <div 
      style="cursor: pointer;" 
      class="home-running-item" 
      @click="gotoProject(item.tag)"
      v-for="(item, index) in runningList" :key="index" >
      <div style="color: #7f83e3;font-size: 1rem;font-weight: 600;">{{ item.name }}</div>
      <div style="font-size: .8rem;color: #999999;">{{ item.tag }}</div>
    </div>

    <div style="font-weight: 600;margin: 10px;">
      历史记录 {{ historyList.length }}个
    </div>
    <div 
      class="home-history-item" 
      style="cursor: pointer;"
      @click="gotoProject(item.tag)"
      v-for="(item, index) in historyList" 
      :key="index" >
      <div style="color: #45b97c;font-size: 1rem;font-weight: 600;">{{ item.name }}</div>
      <div style="font-size: .8rem;color: #999999;">{{ item.tag }}</div>
    </div>

    <div style="font-weight: 600;margin: 10px;">
      常用网站
    </div>
    <div style="display: flex;flex-wrap: wrap;">
      <div v-for="(item, index) in collectionList" :key="index" class="home-collection-item">
        <el-tag 
          closable 
          style="width: 100%;;text-align: center;" 
          effect="plain"
          @click="openUrl(item.address)"
          @close="handleRemoveCollection(index)">
            {{ item.name.length > 15? item.name.substr(0,15) : item.name }}
          </el-tag>
      </div>
      <el-button 
        class="home-collection-item"
        @click="showAddCollectionDialog" 
        size="small"
        icon="el-icon-plus">
        添加
      </el-button>
    </div>

    <el-dialog title="添加常用网站" :visible.sync="addCollectionVisible">
      <div>
        <el-input v-model="dialogInputAddress" placeholder="请输入网址"/>
        <el-input style="margin-top: 1rem;" v-model="dialogInputName" placeholder="请输入网站名称"/>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="addCollectionVisible = false">取 消</el-button>
        <el-button type="primary" @click="handleAddCollection">添 加</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  data() {
    return {
      runningList: [],
      historyList: [],
      collectionList: [],
      addCollectionVisible: false,
      dialogInputAddress: '',
      dialogInputName: ''
    }
  },
  methods: {
    gotoProject (path) {
      this.$router.push({
        path: 'project',
        query: {
          path
        }
      })
    },
    openUrl(url) {
      this.$jsb("openUrl",{path: url})
    },
    showAddCollectionDialog() {
      this.dialogInputAddress = ""
      this.dialogInputName = ""
      this.addCollectionVisible = true
    },
    handleAddCollection() {
      this.addCollectionVisible = false
      this.$jsb("setUserDefaultsArray",{
        path: this.path,
        key: 'user_default_collection',
        value: {name: this.dialogInputName,address: this.dialogInputAddress}
      }).then(res => {
        this.collectionList = res
      })
    },
    handleRemoveCollection(index) {
      this.$alert("是否确认删除该网址？", '删除网址', {
        showCancelButton: true,
        confirmButtonText: "删除",
        cancelButtonText: '取消',
        callback: action => {
          if (action == 'confirm') {
            this.$jsb("removeUserDefaultsArray",{
              key: 'user_default_collection',
              index
            }).then(res => {
              this.collectionList = res
            })
          }
        }
      });  
    }
  },
  created() {
    this.$jsb("getRunningList",{path: this.path})
      .then(res => {
        this.runningList = res.map(item => {
          var info = JSON.parse(item)
          return {
            ...info,
            name: this.getNameFromPath(info.tag)
          }
        })
      })

    this.$jsb("getUserDefaultsDictionary",{key: 'user_default_history'}).then(res => {
      if (res) {
        var list = []
        for(var key in res) {
          var info = res[key]
          list.push({
            ...info,
            name: this.getNameFromPath(info.tag)
          })
        }
        this.historyList = list
      }
    })

    this.$jsb("getUserDefaultsArray",{key: 'user_default_collection'}).then(res => {
      this.collectionList = res
    })
  },
}
</script>

<style>
.home-running-item {
  width: 100%;
  padding: 10px;
  background: #e9f7fb;
  margin: 10px;
}

.home-history-item {
  width: 100%;
  padding: 10px;
  background: #f5faf4;
  margin: 10px;
}

.home-collection-item {
  width: 40%;
  margin: 10px;
  overflow:hidden; 
  text-overflow:ellipsis; 
  white-space:nowrap;
  display: block;
}
</style>