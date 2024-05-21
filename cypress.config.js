const { defineConfig } = require("cypress");

module.exports = defineConfig({
  reporter: 'mochawesome',
  reporterOptions: {
    reportDir: "cypress/reports/mocha",
    reportFilename: "[status]_[datetime]-[name]-report",
    json: true,
    html: false,
  },
  e2e: {
    baseUrl: 'https://www.saucedemo.com/',
    chromeWebSecurity: false,
    blockHosts: [
      '*backtrace.io',
    ],
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
