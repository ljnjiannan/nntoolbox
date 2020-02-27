<template>
  <div style="width: 100%;display: flex;">
    <HomeProjectView style="width: 40%;"/>
    <HomeSearchView style="width: 50%;"/>
  </div>
</template>

<script>
import HomeProjectView from './HomeProjectView'
import HomeSearchView from './HomeSearchView'
export default {
  components: {
    HomeProjectView,
    HomeSearchView
  }
}
</script>

<style>

</style>