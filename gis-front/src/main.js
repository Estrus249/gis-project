/**
 * 应用入口文件
 * - 创建 Vue 应用实例
 * - 导入全局样式（基础布局 + Leaflet CSS）
 * - 挂载到 #app 节点
 */
import { createApp } from 'vue'
import './style.css'                  // 全局基础布局样式
import 'leaflet/dist/leaflet.css'     // Leaflet 控件和弹窗样式（全局导入一次即可）
import App from './App.vue'

createApp(App).mount('#app')
