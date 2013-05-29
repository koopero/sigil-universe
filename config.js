var path = require('path');
var fs = require('fs');

var configFile = path.join ( path.dirname( __filename), "config.json" );
var configContents = fs.readFileSync( configFile,'utf8'); 
extend ( exports, JSON.parse(configContents) );

function extend(target) {
    var sources = [].slice.call(arguments, 1);
    sources.forEach(function (source) {
        for (var prop in source) {
            target[prop] = source[prop];
        }
    });
    return target;
}