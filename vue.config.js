const webpack = require("webpack");
module.exports = {
  configureWebpack: {
    module: {
      rules: [
        {
          test: /\.(glsl|vs|fs|vert|frag)$/i,
          exclude: /node_modules/,
          use: ["raw-loader"],
        },
      ],
    },
  },
  devServer: {
    hotOnly: false,
  },
};
