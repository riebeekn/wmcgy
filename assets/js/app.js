// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import flatpickr from "../vendor/flatpickr";
import BarChart from "./bar-chart";
import LineChart from "./line-chart";
import PieChart from "./pie-chart";

let Hooks = {};
Hooks.DatePicker = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      dateFormat: "M d, Y",
    });
  },
  updated() {
    this.pickr.destroy()
    document.querySelectorAll('[phx-hook="DatePicker"]').forEach((item) => {
      item.pickr = flatpickr(item, {
        dateFormat: "M d, Y",
      });
    });
  },
  destroyed() {
    this.pickr.destroy()
  }
};

Hooks.PieChart = {
  mounted() {
    this.chart = new PieChart(this.el);
    this.handleEvent(
      this.el.dataset.changedEvent,
      ({ labels, values, percentages }) => {
        this.chart.updateData(labels, values, percentages);
      }
    );
  },
};

Hooks.BarChart = {
  mounted() {
    this.chart = new BarChart(this.el);
    this.handleEvent(this.el.dataset.changedEvent, ({ labels, datasets }) => {
      this.chart.updateData(labels, datasets);
    });
  },
};

Hooks.LineChart = {
  mounted() {
    this.chart = new LineChart(this.el);
    this.handleEvent(this.el.dataset.changedEvent, ({ labels, datasets }) => {
      this.chart.updateData(labels, datasets);
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
