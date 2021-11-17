// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}

Hooks.InfiniteScroll = {
  mounted() {
    const observer = new IntersectionObserver(entries => {
      const entry = entries[0];

      if (entry.isIntersecting) {
        this.pushEvent("load-more");
      }
    });

    observer.observe(this.el);
  }
}

let Uploaders = {}

Uploaders.Cloudinary = function(entries, onViewError) {
  entries.forEach(entry => {
    let {url, fields} = entry.meta
    let formData = new FormData()

    formData.append("file", entry.file)
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val))

    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 200 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
          let percent = Math.round((event.loaded / event.total) * 100)
          if(percent < 100){ entry.progress(percent) }
        }
      })

    xhr.open("POST", url, true)
    xhr.send(formData)
  })
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {uploaders: Uploaders, hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

