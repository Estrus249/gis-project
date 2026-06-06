<template>
  <!-- 地图宿主容器，通过 ref 获取真实 DOM 节点供 Leaflet 挂载 -->
  <div ref="mapRef" class="map-container"></div>
</template>

<script setup>
// 分支提交：修复标记图标偏移问题
// 分支开发：优化地图交互体验
// 修复 Marker 图标丢失问题，适配高德底图
/**
 * Map.vue — 基于 Vue3 + Leaflet 的地图组件
 *
 * 功能：
 *   - 初始化 Leaflet 地图，中心固定为重庆江津（29.29°N, 106.25°E）
 *   - 加载高德中文矢量底图（国内稳定加载，多节点负载均衡）
 *   - 在江津坐标添加 Marker 标记点 + Popup 弹窗
 *   - 组件销毁时自动清理地图实例，防止内存泄漏
 *
 * 已知问题修复：
 *   - Vite 打包后 Leaflet 默认 Marker 图标路径丢失，
 *     需手动导入图片资源并重写 L.Icon.Default 配置
 */
import { onMounted, onBeforeUnmount, ref } from 'vue'
import L from 'leaflet'

// ===================== 修复 Vite 环境下 Marker 图标丢失 =====================
// Leaflet 默认通过 CSS 相对路径引用 marker-icon.png 等图片，
// 但 Vite 的模块化打包机制无法正确解析这些路径，导致生产环境图标不显示。
// 解决方案：显式导入图片资源，用 Vite 的 asset 处理获得正确 URL，
// 然后重写 L.Icon.Default 的默认配置。
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'

// 删除 Leaflet 内部默认的 _getIconUrl 方法，阻止其使用原始相对路径
delete L.Icon.Default.prototype._getIconUrl

// 将 Vite 处理后的图片 URL 注入到 Leaflet 图标默认配置中
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,   // 高清屏（Retina）图标
  iconUrl: markerIcon,           // 标准图标
  shadowUrl: markerShadow        // 图标阴影
})

// ===================== 常量定义 =====================

/** 重庆江津坐标：[纬度, 经度] */
const CENTER = [29.29, 106.25]

/** 初始缩放级别（7 级 ≈ 省级视野范围） */
const ZOOM = 7

/** 瓦片图层最小缩放级别 */
const MIN_ZOOM = 3

/** 瓦片图层最大缩放级别 */
const MAX_ZOOM = 18

/** 高德中文矢量底图瓦片 URL 模板
 *  - {s}: 子域名占位符，Leaflet 自动从 subdomains 数组轮询，实现负载均衡
 *  - lang=zh_cn: 中文标注
 *  - size=1: 256×256 标准瓦片尺寸
 *  - style=7: 高德标准路网 + 中文标注样式
 *  - {x}/{y}/{z}: 瓦片列号/行号/缩放级别占位符
 */
const TILE_URL =
  'https://{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}'

/** 高德瓦片服务器子域名列表，Leaflet 自动轮询实现负载均衡 */
const TILE_SUBDOMAINS = ['wprd01', 'wprd02', 'wprd03', 'wprd04']

/** 版权声明（显示在地图右下角） */
const ATTRIBUTION = '&copy; 高德地图'

/** 标记点弹窗文字 */
const MARKER_POPUP = '重庆江津GIS项目点位'

// ===================== 响应式变量 =====================

/** 地图容器的模板引用，挂载后指向真实 DOM 节点 */
const mapRef = ref(null)

/** Leaflet 地图实例（非响应式，纯 JS 对象无需 Vue 追踪） */
let map = null

/** 标记点图层引用，用于后续可能的清理或操作 */
let markerLayer = null

// ===================== 生命周期 =====================

/**
 * 组件挂载后初始化地图
 * 必须在 onMounted 中执行，因为 Leaflet 需要真实 DOM 节点才能工作
 */
onMounted(() => {
  // 1. 创建地图实例，指定容器 DOM 和初始视图
  map = L.map(mapRef.value, {
    center: CENTER,            // 地图中心：重庆江津
    zoom: ZOOM,                // 初始缩放级别
    zoomControl: true,         // 显示缩放控件（左上角 +/- 按钮）
    attributionControl: true   // 显示版权控件（右下角声明）
  })

  // 2. 加载高德中文矢量瓦片底图
  L.tileLayer(TILE_URL, {
    minZoom: MIN_ZOOM,                      // 最低缩放级别
    maxZoom: MAX_ZOOM,                      // 最高缩放级别
    subdomains: TILE_SUBDOMAINS,            // 多节点轮询，提升加载稳定性
    attribution: ATTRIBUTION                // 版权信息
  }).addTo(map)   // 将瓦片图层添加到地图

  // 3. 在江津坐标添加标记点，绑定弹窗并自动打开
  markerLayer = L.marker(CENTER).addTo(map)
  markerLayer.bindPopup(MARKER_POPUP).openPopup()
})

/**
 * 组件销毁前清理地图实例
 * 调用 map.remove() 会移除所有图层、事件监听器、DOM 元素，
 * 防止组件销毁后残留的监听器导致内存泄漏或"幽灵地图"
 */
onBeforeUnmount(() => {
  if (map) {
    map.remove()
    map = null          // 置空引用，防御 KeepAlive 缓存场景下的重复初始化
  }
  markerLayer = null    // 置空标记图层引用
})
</script>

<style scoped>
/* 地图容器：占满父元素 100% 宽高，由外部 #app 提供 100vh 全屏高度 */
.map-container {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}
</style>
