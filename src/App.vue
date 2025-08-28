<script setup lang="ts">
import { RouterView } from 'vue-router'
import 'mdui/mdui.css'
import 'mdui'
// 初始化 Microsoft Clarity 服务
import Clarity from '@microsoft/clarity'

const projectId = <string>import.meta.env.VITE_MICROSOFT_CLARITY_PROJECT_ID
Clarity.init(projectId)
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
