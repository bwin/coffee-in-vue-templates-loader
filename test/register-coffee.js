
const coffee = require('coffeescript');

const { compile } = coffee;

// workaround to provide options to register
coffee.compile = (file, options) => (
  compile(file, Object.assign(options, {
    transpile: {
      presets: ['@babel/env']
    }
  }))
);

coffee.register();
