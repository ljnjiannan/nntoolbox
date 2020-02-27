const path = require('path');

module.exports = {
  configureWebpack: config => {
    return {
      resolve: {
        alias: {
          "@": path.resolve(__dirname, 'src/'),
          "@view": path.resolve(__dirname, 'src/pages'),
          "@components": path.resolve(__dirname, 'src/components'),
          "@assets": path.resolve(__dirname, 'src/assets')
        }
      },
    }
  }
}