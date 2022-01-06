const TodoList = {
  data() {
    return {
      isBodyShow: false,
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
      vehInfo: [""], // server
      charinfo: [""],
      settingsCheckbox1: false,
      theme: "style-light",
      cardImageColor: "invert_disable",
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
    },
    Alert(msg, color) {
      this.alert.show = true;
      this.alert.msg = msg;
      this.alert.show = color;
      setTimeout(() => {
        this.alert.show = false;
      }, 1500);
    },
    toggleTheme(state) {
      if (state === !true) {
        this.theme = "style-light";
        this.cardImageColor = "invert_disable";
      } else {
        this.theme = "style-dark";
        this.cardImageColor = "invertF";
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
      console.log(serverRes);
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
      console.log(s.target.children[0]._value);
      s.target.children[0].focus();
      s.target.children[0].select();
      document.execCommand("copy");
      this.Alert("Copied to clipboard", "style-success");
    },
    Open() {
      $("#app").fadeIn(150);
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
      this.upgrades = [];
    },
  },
  mounted() {
    this.$nextTick(function () {
      var self = this;
      window.addEventListener("message", function (event) {
        //
        console.log(event);
        switch (event.data.action) {
          case "open":
            self.init(event.data.data);
            self.Open();
            break;
          case "close":
            self.closeMenu()
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
