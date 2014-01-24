(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  require.config({
    baseUrl: '../scripts',
    paths: {
      'sinon-chai': '../bower_components/sinon-chai/lib/sinon-chai'
    }
  });

  require(['sinon-chai', '../spec/util/testme'], function(sinonChai) {
    chai.use(sinonChai);
    chai.should();
    if (window.mochaPhantomJS) {
      return mochaPhantomJS.run();
    } else {
      return mocha.run();
    }
  });

}).call(this);

},{}]},{},[1])