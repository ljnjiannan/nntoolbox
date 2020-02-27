import jsbridge from './jsbridge'
import moment from 'moment'

export default {
  install:function(Vue){
    Vue.prototype.moment = moment
    Vue.prototype.loadSwift = (name, body) => {
      window.webkit.messageHandlers[name].postMessage(body);
    }
    Vue.prototype.bindFunction = (funcName) => {
      var name = funcName.name.replace("bound","").trim()
      name = "swift" + name.charAt(0).toUpperCase() + name.slice(1)
      window[name] = funcName
    }
    Vue.prototype.getNameFromPath = (path) => {
      if (!path) {
        return "nu"
      }

      var paths = path.split("/")
      if (!paths.length) {
        return "no"
      }
      return paths[paths.length - 1]
    }
    Vue.prototype.$jsb = jsbridge.loadJs
    Vue.prototype.$bindSwift = jsbridge.bingSwift
    Vue.prototype.openUrl = jsbridge.loadJs
    String.prototype.startWith=function(str){    
      var reg=new RegExp("^"+str);    
      return reg.test(this);       
    } 
  }
}