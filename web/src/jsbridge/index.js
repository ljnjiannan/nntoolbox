

var callBackList = {}
var bingdingList = {}

window.swiftBridge = (body) => {
  let resolve = callBackList[body.name]
  if (resolve) {
    resolve(body.result)
    delete callBackList[body.name]
  }
}

window.swiftBindingBridge = (body) => {
  let callback = bingdingList[body.name]
  if (callback) {
    callback(body.result)
  }  
}

const bingSwift = (name, callback) => {
  if (bingdingList[name]) {
    return
  }
  bingdingList[name] = callback
}

const loadJs = (name, params) => {
  const ua = window.navigator.userAgent.toLowerCase()
  if (ua.indexOf("safari") >= 0 || ua.indexOf("chrome") >= 0 ) {
    var pr = new Promise((_,reject) => {
      reject("test")
    })
    return pr
  } else {
    return new Promise((resolve) => {
      callBackList[name] = resolve
      window.webkit.messageHandlers["jsBridge"].postMessage({
        name,
        body: params
      });
    })
  }
}


export default {loadJs, bingSwift}