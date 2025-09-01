<template>
  <div>
    <ShopMenuItem
      :wagon="wagon"
      :index="index"
      :selected="activeDropdown"
      v-for="(wagon, index) in wagons"
      :key="index"
      @iExpanded="onChildExpansion($event, index)"
    />
  </div>
</template>

<script>
import ShopMenuItem from "./ShopMenuItem.vue";
import { mapState } from "vuex";
export default {
  name: "ShopMenu",
  data() {
    return {
      activeDropdown: -1,
    };
  },
  methods: {
    onChildExpansion(event) {
      this.activeDropdown = event;
    },
  },
  components: {
    ShopMenuItem,
  },
  computed: mapState(["wagons"]),
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss"></style>
