const TodoList = {
  data() {
    return {
      isBodyShow: false,
      selectedIndex: 0,
      tabs: [
        {
          id: 1,
          name: "Vehicle data",
          panel: "first-1",
        },
        {
          id: 2,
          name: "Vehicle history",
          panel: "first-2",
        },
        {
          id: 3,
          name: "Payment history",
          panel: "first-3",
        },
        {
          id: 4,
          name: "Settings",
          panel: "first-4",
        },
      ],
      stepPrice: null,
      upgradeOptions: [],
      vehInfo: [], // server
      charinfo: [{ firstname: "alin" }],
      settingsCheckbox1: false,
      theme: {
        0: "bg-dark-c text-gray-100",
        1: "bg-dark-card-c text-white-c",
      },
      tablet_animation: "tablet-animation",
      // alerts meta data
      alert: {
        show: false,
        msg: "init",
        color: "style-success",
      },
    };
  },
  watch: {
    settingsCheckbox1(value, oldValue) {
      // watch settingsCheckbox1 to toggle theme
      this.toggleTheme(value);
    },
  },
  methods: {
    selectTab(i) {
      this.selectedIndex = i;
      // loop over all the tabs
      this.tabs.forEach((tab, index) => {
        tab.isActive = index === i;
      });
    },
    upgrade() {
      // handle upgrade btn
      let size = Object.keys(this.upgradeOptions).length;
      let upgrades = [];

      for (let index = 0; index < size; index++) {
        let element = document.getElementById(`my-checkbox-id-${index + 1}`);
        let checked = element.checked;
        if (element.disabled) {
          checked = element.disabled;
        }
        upgrades.push(checked);
      }

      let data = {
        upgrade: upgrades,
        plate: this.vehInfo.plate,
        hash: this.vehInfo.hash,
        model: this.vehInfo.model,
        class: this.vehInfo.class,
      };

      upgradeReq(data);
    },
    toggleBody() {
      // toggle Display on Body
      this.isBodyShow = !this.isBodyShow;
      this.tablet_animation = this.tablet_animation ?  "tablet-animation" : ""
    },
    Alert(msg, color) {
      this.alert.show = true;
      this.alert.msg = msg;
      this.alert.color = color;
      setTimeout(() => {
        this.alert.show = false;
      }, 1500);
    },
    toggleTheme(state) {
      if (state === true) {
        this.theme[0] = "bg-light text-dark-100";
        // for some reason bg-light is not white and we need to pass it empty to stay white! (class ==> card)
        this.theme[1] = "";
      } else {
        this.theme[0] = "bg-dark-c text-white-c";
        this.theme[1] = "bg-dark-card-c text-white-c";
      }
    },
    changeActiveClass(value) {
      return {
        "tab-panel show": value == 1,
        "tab-panel": value > 1,
      };
    },
    changeActiveButton(value) {
      return {
        "tab-button active": value == 1,
        "tab-button": value > 1,
      };
    },
    init(serverRes) {
      this.vehInfo = {
        class: serverRes.vehicleInfo.class,
        model: serverRes.vehicleInfo.vehicle,
        plate: serverRes.vehicleInfo.plate,
        hash: serverRes.vehicleInfo.hash,
        currentWeight: serverRes.vehicleInfo.maxweight,
      };
      this.charinfo = serverRes.characterInfo;

      let size = Object.keys(serverRes.upgrades).length;
      let upgrades = serverRes.upgrades;
      this.stepPrice = serverRes.upgrades.stepPrice;

      for (let index = 1; index < size - 1; index++) {
        this.upgradeOptions.push({
          id: index,
          name: `+${upgrades.step / 1000}Kg`,
          active: upgrades[index],
          dataID: `id-${index}`,
        });
      }

      // upgradeOptions
    },
    copy(s) {
      s.target.focus();
      s.target.select();
      document.execCommand("copy");
      this.Alert("Copied to clipboard", "style-success");
    },
    Open() {
      $("#app").fadeIn(350);
      this.toggleBody();
    },
    closeMenu() {
      $("#app").fadeOut(550);
      $.post("https://keep-carInventoryWeight/closeMenu");
      this.toggleBody();
      this.reset();
    },
    reset() {
      this.upgradeOptions = [];
      this.vehInfo = [];
      this.charinfo = [];
      this.stepPrice = null;
    },
  },
  mounted() {
    this.$nextTick(function () {
      var self = this;
      window.addEventListener("message", function (event) {
        //
        switch (event.data.action) {
          case "open":
            self.init(event.data.data);
            self.Open();
            break;
          case "close":
            self.closeMenu();
            break;
        }
      });
      document.onkeyup = function (data) {
        if (data.key == "Escape") {
          self.closeMenu();
        }
      };
    });
  },
};

const app = Vue.createApp(TodoList);

app.mount("#app");

function upgradeReq(data = {}, cb = () => {}) {
  fetch(`https://keep-carInventoryWeight/upgradeReq`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data),
  })
    .then((resp) => resp.json())
    .then((resp) => cb(resp));
}
