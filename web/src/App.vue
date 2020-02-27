<template>
  <div id="app" @touchmove.prevent>
    <router-view style="height: 100%;"></router-view>
    <SettingView />
  </div>
</template>

<script>
import SettingView from '@view/setting'

export default {
  name: 'app',
  components: {SettingView},
  created() {
    // this.$jsb("initRunngingList", {path: this.path})
    //   .then(() => {
    //   })
    window.openDialog = (body) => {
        this.$alert(body, '', {
          showCancelButton: true,
          confirmButtonText: "关闭",
          cancelButtonText: '取消',
          callback: action => {
            if (action == 'confirm') {
              this.$jsb("terminalAllTask",{})
            }
          }
        });  
    }
  }
}
</script>

<style lang='stylus'>
body {
  overflow hidden;
  height 100vh;
  margin: 0;
  moz-user-select: -moz-none;
}
* {
  // -moz-user-select: none;
  // -o-user-select:none;
  // -khtml-user-select:none;
  // -webkit-user-select:none;
  // -ms-user-select:none;
  // user-select:none;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: left;
  color: #2c3e50;
  margin-top: 20px;
  font-size: 16px;
  overflow hidden;
  height 100%;
}

</style>
