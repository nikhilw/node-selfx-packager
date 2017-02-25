"use strict";
var _ = require("lodash");
var fs = require("fs");
var log = console.log;

process.title = process.argv[2] || process.title;
// Your first param is the process name.
log("Now this process is called: '" + process.title + "', go check in system monitor.");

//You are free to use yargs or optimist.

const defaults = {
	bringBackRobb: true,
	johnSnowSitsOnThonre: false,
	delaySeasonBy: 2
};

// Your second param is the application.json file in pwd, place where you are running the command from.
// You are of course free to use a config manager like nconf.
var options = {};
if (process.argv[3] && fs.existsSync(process.argv[3])) {
	options = JSON.parse(fs.readFileSync(process.argv[3], "utf8"));
};

var config = _.merge({}, defaults, options);

log("npm modules work too, with lodash configuration now looks like: ", config);

// write your code here.
log("Uncomment code below to keep the process live long enough for you to check system monitor.");
// setInterval(function() {
// 	log("waiting...");
// }, 2000);