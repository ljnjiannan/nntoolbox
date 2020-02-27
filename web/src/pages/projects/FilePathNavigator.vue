
<template>
  <div class="file-path-navigator-view">
    <div class="file-path-navigator-view-item" 
      v-for="(item, index) in paths" 
      :key="index" 
      @click="itemClick(item)" >
      <span :style="index != paths.length - 1? 'color: gray;':'color: blue;'">{{ item.name }}</span>
      <div style="color: #d3d3d3" v-if="index != paths.length - 1">></div>
    </div>
  </div>
  <!-- <el-breadcrumb separator-class="el-icon-arrow-right"  >
    <el-breadcrumb-item @click="itemClick"  v-for="(item, index) in paths" :key="index">
      {{ item.name }}
    </el-breadcrumb-item>
    <div @click="itemClick">hahahah</div>
  </el-breadcrumb> -->
</template>

<script>
export default {
  name: 'file-path',
  props: {
    paths: {
      type: Array
    }
  },
  created() {
  },
  methods: {
    itemClick (item) {
      this.$emit('pathClick', item)
    }
  }
}
</script>

<style lang="stylus" scoped>
.file-path-navigator-view {
  display flex;
  height 3rem;
  line-height 3rem;
  text-align center;
}

.file-path-navigator-view-item {
  cursor pointer
  display flex;
  span {
    margin 0 10px;
  }
  div {
    margin 0 10px;
  }
}
</style>
