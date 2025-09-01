import { createRouter, createWebHashHistory } from "vue-router";
import WagonMenu from "../views/WagonMenu.vue";

const routes = [
  {
    path: "/",
    name: "home",
    component: WagonMenu,
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
