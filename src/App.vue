<script setup lang="ts">
import { RouterView } from 'vue-router'
import 'mdui/mdui.css'
import 'mdui'
import { onMounted } from 'vue'

// 初始化 Microsoft Clarity 服务
import Clarity from '@microsoft/clarity'
const clarityId = <string>import.meta.env.VITE_MICROSOFT_CLARITY_PROJECT_ID
Clarity.init(clarityId)

// 初始化 Google Analytics
const gaId = import.meta.env.VITE_GOOGLE_ANALYTICS_ID
onMounted(() => {
  // 动态加载 Google Analytics 脚本
  const script = document.createElement('script')
  script.async = true
  script.src = `https://www.googletagmanager.com/gtag/js?id=${gaId}`
  document.head.appendChild(script)

  // 初始化 gtag
  window.dataLayer = window.dataLayer || []
  function gtag(...args: unknown[]) {
    window.dataLayer.push(args)
  }
  gtag('js', new Date())
  gtag('config', gaId)
})

// 为 gtag 添加类型声明
declare global {
  interface Window {
    dataLayer: unknown[][]
  }
}
</script>

<template>
  <RouterView />
</template>

<style>
/* 隐藏所有未注册的 mdui 组件，并在组件注册完成后立即显示： */
:not(:defined) {
  visibility: hidden;
}
</style>
