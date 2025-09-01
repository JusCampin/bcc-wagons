import { createStore } from "vuex";

export default createStore({
  state: {
    myWagons: null,
    wagons: null,
    shopName: null,
    activeWagon: null,
    allowSave: false,
    currencyType: null,
    translations: {}
  },
  getters: {
    getTranslation: (state) => (key) => {
      return state.translations[key] ?? ''
    }
  },
  mutations: {
    SET_MY_WAGONS(state, payload) {
      state.myWagons = payload;
    },
    SET_WAGONS(state, payload) {
      state.wagons = payload;
    },
    SET_SHOP_NAME(state, payload) {
      state.shopName = payload;
    },
    SET_TRANSLATIONS(state, payload) {
      state.translations = payload;
    },
    SET_SELECTED_WAGON(state, payload) {
      state.activeWagon = payload;
    },
    SET_ALLOW_SAVE(state, payload) {
      state.allowSave = payload;
    },
    SET_CURRENCY_TYPE(state, payload) {
      state.currencyType = payload;
    },
  },
  actions: {
    setMyWagons(context, payload) {
      context.commit("SET_MY_WAGONS", payload);
    },
    setWagons(context, payload) {
      context.commit("SET_WAGONS", payload);
    },
    setShopName(context, payload) {
      context.commit("SET_SHOP_NAME", payload);
    },
    setTranslations(context, payload) {
      context.commit("SET_TRANSLATIONS", payload);
    },
    setSelectedWagon(context, payload) {
      context.commit("SET_SELECTED_WAGON", payload);
    },
    setAllowSave(context, payload) {
      context.commit("SET_ALLOW_SAVE", payload);
    },
    setCurrencyType(context, payload) {
      context.commit("SET_CURRENCY_TYPE", payload);
    }
  },
  modules: {},
});
