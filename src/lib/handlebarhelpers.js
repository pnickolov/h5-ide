(function() {
  define(["handlebars", "i18n!nls/lang.js"], function(Handlebars, lang) {
    Handlebars.registerHelper('i18n', function(text) {
      var t;
      t = lang.ide[text] || "";

      /* env:dev */
      t = t || "undefined";

      /* env:dev:end */
      return new Handlebars.SafeString(t);
    });
    Handlebars.registerHelper('tolower', function(result) {
      return new Handlebars.SafeString(result.toLowerCase());
    });
    Handlebars.registerHelper('emptyStr', function(v1) {
      if (v1 === '' || v1 === (void 0) || v1 === null) {
        return '-';
      } else {
        return new Handlebars.SafeString(v1);
      }
    });
    Handlebars.registerHelper('UTC', function(text) {
      return new Handlebars.SafeString(new Date(text).toUTCString());
    });
    Handlebars.registerHelper('breaklines', function(text) {
      text = Handlebars.Utils.escapeExpression(text);
      text = text.replace(/(\r\n|\n|\r)/gm, '<br>');
      return new Handlebars.SafeString(text);
    });
    Handlebars.registerHelper('nl2br', function(text) {
      var nl2br;
      nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2');
      return new Handlebars.SafeString(nl2br);
    });
    Handlebars.registerHelper('ifCond', function(v1, v2, options) {
      if (v1 === v2) {
        return options.fn(this);
      }
      return options.inverse(this);
    });
    Handlebars.registerHelper('timeStr', function(v1) {
      var d;
      d = new Date(v1);
      if (isNaN(Date.parse(v1)) || !d.toLocaleDateString || !d.toTimeString) {
        if (v1) {
          return new Handlebars.SafeString(v1);
        } else {
          return '-';
        }
      }
      d = new Date(v1);
      return d.toLocaleDateString() + " " + d.toTimeString();
    });
    Handlebars.registerHelper("plusone", function(v1) {
      v1 = parseInt(v1, 10);
      if (isNaN(v1)) {
        return v1;
      } else {
        return '' + (v1 + 1);
      }
    });
    return null;
  });

}).call(this);
