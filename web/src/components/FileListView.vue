<template>
  <div>
    <!-- {{ files }} -->
    <div v-for="(item, key) in files" :key="key">
      <div v-if="item.length == undefined">
        <div style="display: flex;align-items: center;">
          <i style="margin-right: 6px;color: #6477f8;" class='el-icon-folder-opened' /><span>{{ key }}</span>
        </div>
        <div style="display: flex;margin-left: 1rem;">
          <file-list-view :files='item' @addFile="addFile">
          </file-list-view>
        </div>
      </div>

      <div 
        class="file-list-view-files"
        v-else-if="item.length" 
        v-for="file in item" 
        :key="file.path">
        <div style="text-align: left;">
          <i :style="getFileStyle(file.type)" style="padding-right: 4px;margin-right: 6px;height: 1rem;"/>
          <span>{{ getNameFromPath(file.path) }}</span>
        </div>
        <div>
          <el-button 
            v-show="file.type.substr(0,1)==' ' ||  file.type == '??'"
            @click="itemClick(file.path)" type="text" >添加</el-button>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'FileListView',
  props: {
    files: Object
  },
  methods: {
    getFileStyle(type) {
      switch (type) {
        // 修改的文件
        case " M":
          return {
            width: "10px",
            background: "#f5c24f"
          }
        // 删除的文件
        case " D":
          return {
            background: "#999999"
          }
        case "??":
          return {
            background: '#554b81'
          }
        case 'M ':
        case "D ":
        case "A ":
        case "AM":
          return {
            background: "green"
          }
      }
    },
    addFile(file) {
      this.$emit("addFile", file)
    },
    itemClick(file) {
      this.$emit("addFile", file)
    }
  }
}
</script>

<style lang='stylus' scope>
.file-list-view-files {
  width 14rem;
  padding-right 10px;
  display flex;
  align-items center;
  justify-content space-between;
}
</style>