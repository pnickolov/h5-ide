
define([], function(){

  function isArray(value) {
      return value && typeof value === "object" && value.constructor === Array;
  }

  function typeofReal(value) {
    return isArray(value) ? "array": value === null ? 'null' : typeof value;
  }

  function typeString( value ) {
    if ( !value ) { return typeofReal(value); }

    if ( value.uid ) {
      c = Design.instance().component( value.uid );
      if (c)
        value = c;
    }
    if ( value.type ) {
      return value.type.replace("AWS.", "").replace("EC2.","").replace("VPC.","").replace("AutoScaling.LaunchConfiguration", "LC");
    } else {
      if ( isArray(value) ) {
        if ( value.length ) {
          return "Array"
        } else {
          return "EmptyArray"
        }
      } else if ( value === null ) {
        return "Null"
      } else {
        return "Object"
      }
    }
  }

  var n = 0;

  var jsond = {

    version: "0.0.1",

    a: [], // first structure
    b: [], // second structure

    feedback : function(node) {
      // node.setAttribute('id', 'change-' + n);
      // n += 1;
      // var nextNode = document.createElement('a');
      // nextNode.setAttribute('href', '#change-' + n);
      // nextNode.appendChild(document.createTextNode('\u2193 next change \u2193'));
      // node.appendChild(nextNode);
    },

    swap: function(fn) {
      this.a = [this.b, this.b = this.a][0];
      fn(this.a, this.b);
    },

    clear: function(fn) {
      this.a = this.b = {};
      fn(this.a, this.b);
    },

    compare: function(a, b, name, results, fn) {

      // To-Do: a and/or b should accept a uri or a json structure.
      // To-Do: this DOM manipulation should be seperated into logic and rendering so that it works with nodejs.

      n = 0;

      var self = this;

      var typeA = typeofReal(a);
      var typeB = typeofReal(b);

      var typeSpanA = document.createElement("span");
      typeSpanA.appendChild(document.createTextNode(typeString(a)));
      typeSpanA.setAttribute("class", "typeName");

      var typeSpanB = document.createElement("span");
      typeSpanB.appendChild(document.createTextNode(typeString(b)));
      typeSpanB.setAttribute("class", "typeName");

      var aString = (typeA === "object" || typeA === "array") ? "": String(a) + "";
      var bString = (typeB === "object" || typeB === "array") ? "": String(b) + "";

      if ( typeA == "string" ) { aString = '"' + aString + '"'; }
      if ( typeB == "string" ) { bString = '"' + bString + '"'; }

      var childNodeType = "span";
      if ( aString.indexOf("\n") > -1 || bString.indexOf("\n") > -1 )
      {
        childNodeType = "pre";
      }

      var leafNode = document.createElement("span");
      spanNode = document.createElement("span");
      spanNode.appendChild(document.createTextNode(name + ": "))
      leafNode.appendChild(spanNode);


      if (a === undefined && b !== undefined)
      {
          leafNode.setAttribute("class", "added");
          valueNode = document.createTextNode(bString);

          if( typeB == "number" || typeB == "string" || typeB == "boolean" )
          {
            spanNode = document.createElement(childNodeType);
            spanNode.setAttribute("class", typeB )
            spanNode.appendChild( valueNode )
            leafNode.appendChild(spanNode);
          } else {
            leafNode.appendChild(valueNode);
            leafNode.appendChild(typeSpanB);
          }

          self.feedback(leafNode);
      }
      else if (b === undefined && a !== undefined)
      {
          leafNode.setAttribute("class", "removed");
          valueNode = document.createTextNode(aString);

          if( typeA == "number" || typeA == "string" || typeA == "boolean" )
          {
            spanNode = document.createElement(childNodeType);
            spanNode.setAttribute("class", typeA )
            spanNode.appendChild( valueNode )
            leafNode.appendChild(spanNode);
          } else {
            leafNode.appendChild(valueNode);
            leafNode.appendChild(typeSpanA);
          }

          self.feedback(leafNode);
      }
      else if (typeA !== typeB || (typeA !== "object" && typeA !== "array" && a !== b))
      {
          leafNode.setAttribute("class", "changed");

          valueNode = document.createTextNode(aString);
          if( typeA == "number" || typeA == "string" || typeA == "boolean" )
          {
            spanNode = document.createElement(childNodeType);
            spanNode.setAttribute("class", typeA )
            spanNode.appendChild( valueNode )
            leafNode.appendChild(spanNode);
          } else {
            leafNode.appendChild(valueNode);
            leafNode.appendChild(typeSpanA);
          }

          leafNode.appendChild(document.createTextNode(" => "));
          valueNode = document.createTextNode(bString);
          if( typeB == "number" || typeB == "string" || typeB == "boolean" )
          {
            spanNode = document.createElement(childNodeType);
            spanNode.setAttribute("class", typeB )
            spanNode.appendChild( valueNode )
            leafNode.appendChild(spanNode);
          } else {
            leafNode.appendChild(valueNode);
            leafNode.appendChild(typeSpanB);
          }

          if (name === 'key') leafNode.setAttribute('class', 'changed key');
          else self.feedback(leafNode);
      }
      else
      {
          valueNode = document.createTextNode(aString);
          if( typeA == "number" || typeA == "string" || typeA == "boolean" )
          {
            spanNode = document.createElement(childNodeType);
            spanNode.setAttribute("class", typeA )
            spanNode.appendChild( valueNode )
            leafNode.appendChild(spanNode);
          } else {
            leafNode.appendChild(valueNode);
            leafNode.appendChild(typeSpanA);
          }
      }

      if (typeA === "object" || typeA === "array" || typeB === "object" || typeB === "array")
      {
          var keys = [];
          for (var i in a) keys.push(i);
          for (var i in b) keys.push(i);
          keys.sort();

          var listNode = document.createElement("ul");
          listNode.setAttribute("class", "closed");
          listNode.appendChild(leafNode);

          for (var i = 0; i < keys.length; i++)
          {
              if (keys[i] === keys[i - 1])
              continue;

              var li = document.createElement("li");
              listNode.appendChild(li);

              self.compare(a && a[keys[i]], b && b[keys[i]], keys[i], li);
          }

          results.appendChild(listNode);
      }
      else
      {
          results.appendChild(leafNode);
      }

    }

  };

  return jsond;
})
