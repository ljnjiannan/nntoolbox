<template>
  <div>
    <el-input 
      placeholder="搜索Github" 
      v-model="searchValue" 
      style="width: 100%;margin: 3rem;"
      @keyup.enter.native='searchGithub'>
      <el-button slot="append" @click="searchGithub" icon="el-icon-search"></el-button>
    </el-input>
    <div style="overflow: scroll;height: 60%;margin: 0 3rem;" v-loading="loading">
      <div v-for="item in resultList" :key="item.id" class="search-github-item">
        <div style="color: blue;" @click="openUrl(item.url)">{{ item.name}} </div>
        <div class="search-github-item-subscibe">
          <div>{{ item.language }} | {{ item.star }} | update: {{ item.update }}</div>
        </div>
      </div>
    </div>
    <el-pagination
      style="margin-top: 1rem;margin-left: 3rem;"
      :current-page.sync="currentPage"
      background
      layout="prev, pager, next"
      :total="resultCount"
      :page-size='pageSize'
      @current-change='searchGithub'
      hide-on-single-page
      >
    </el-pagination>
  </div>
</template>

<script>
import axios from 'axios'
export default {
  data() {
    return {
      searchType: '',
      searchValue: '',
      searchResult: {},
      resultCount: 0,
      resultList: [],
      currentPage: 1,
      pageSize: 10,
      loading: false
    }
  },
  created() {
    // axios.get("https://api.github.com/search/repositories?q=js+websockets")
    //   .then(res => {
    //     this.searchResult = res
    //   })
  },
  methods: {
    searchGithub() {
      const keywords = this.searchValue.replace(" ","+")
      this.loading = true
      axios.get("https://api.github.com/search/repositories",{
        params: {
          q: keywords,
          per_page: this.pageSize,
          page: this.currentPage
        }
      })
      .then(res => {
        this.loading = false
        const data = res.data
        if (data.total_count > this.pageSize * 100) {
          this.resultCount = this.pageSize * 100
        } else {
          this.resultCount = data.total_count
        }
        this.resultList = data.items.map(item => {
          var star = item.watchers_count
          const moment = this.moment(item.updated_at)
          if (star > 1000) {
            star = (star / 1000).toFixed(1) + 'k'
          }
          return {
            id: item.id,
            name: item.full_name,
            url: item.html_url,
            language: item.language,
            star,
            update: moment.format("YYYY-MM-DD")
          }
        })
      })
      .catch((err) => {
        this.$message({
          showClose: true,
          message: err.toJSON().message,
          type: 'error'
        })
        this.loading = false
      })
    },
    openUrl(url) {
      this.$jsb("openUrl",{path: url})
    }
  }
}
</script>

<style lang="stylus" scoped>
.search-github-item
  border 1px solid #c4c4c4 
  border-radius 10px
  margin 10px
  padding 10px

.search-github-item-subscibe
  font-size .8rem
  color #999999
</style>>
