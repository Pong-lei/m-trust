<template>
  <Mtrust/>
</template>

<script>
import Mtrust from './components/Mtrust.vue'

export default {
  name: 'App',
  components: {
    Mtrust
  }
}
</script>

<style>
*{
  margin: 0;
  padding: 0;
}
:-webkit-scrollbar {
  width: 0 !important;
}
::-webkit-scrollbar {
  width: 0 !important;
  height: 0;
}
</style>
