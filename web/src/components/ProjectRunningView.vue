<template>
  <div style="width: 30%;">
    <el-collapse accordion>
      <el-collapse-item 
        v-for="(item, index) in getRunningInfo" 
        :key="index" >
        <template slot="title">
          {{getNameFromPath(item.name)}}
          <el-tag @click.stop="terninateScript(item.name)" style="margin-left: 1rem;">停止</el-tag>
        </template>
        
        <div v-html='item.log'></div>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script>
export default {
  props: {
    scriptList: Array
  },
  computed: {
    getRunningInfo() {
      return this.scriptList.map(item => {
        return JSON.parse(item)
      })
    }
  },
  methods: {
    terninateScript(path) {
      this.loadSwift("jsTerminateScript",path)
    },
  }

}
</script>