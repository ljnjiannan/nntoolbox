<template>
  <div style="height: 100%;width: 20rem;overflow: scroll;">
    <div v-for="(item, index) in getList" 
      :key="index"
      @click="$emit('dirClick',item)"
      class="folder-list"
      >
      <div class="folder-list-item" >
        <img style="height: 1rem;" :src="require(item.isFolder? '@/assets/ic_dir.png':'@/assets/ic_file.png')" />
        <div>{{ item.name }}</div>
        <el-tag 
          v-if="item.folderType" 
          type="success" 
          style="margin-left: 1rem;"
          size='small'>
          {{ item.folderType }}
        </el-tag>
      </div>
      

    </div>
  </div>
</template>

<script>
export default {
  props: {
    list: {
      type: Array
    }
  },
  computed: {
    getList () {
      return this.list.map(res => {
        return JSON.parse(res)
      })
    },
  }
}
</script>

<style lang="stylus" scoped>
.folder-list {
  align-items center;
  padding-left: 1rem;
  width: 20rem;
  line-height 2.5rem;
  background white;
  img {
    margin-right 10px;
  }
}
.folder-list:nth-child(odd) {
  background #f7fbff;
}
.folder-list-item
  display:flex;
  align-items: center;

  div 
    font-weight: 600;
    width: 70%;
    overflow: hidden;
    text-overflow:ellipsis;
    white-space: nowrap;
</style>
