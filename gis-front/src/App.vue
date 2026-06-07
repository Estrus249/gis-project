<template>
  <!-- 全屏地图组件 -->
  <div class="map-container">
    <Map />
  </div>
</template>

<script setup>
// 引入自定义地图组件
import Map from './components/Map.vue'
</script>

<style scoped>
.map-container {
  width: 100%;
  height: 100vh;
}