__meteor_runtime_config__ = {"meteorRelease": "0.6.3.1","ROOT_URL": "http://localhost:3000","serverId": "gtiMof6XofPYAwNhp"};
Meteor = {isClient: !0,isServer: !1}, "undefined" != typeof __meteor_runtime_config__ && __meteor_runtime_config__ && __meteor_runtime_config__.PUBLIC_SETTINGS && (Meteor.settings = {"public": __meteor_runtime_config__.PUBLIC_SETTINGS}), __meteor_runtime_config__.meteorRelease && (Meteor.release = __meteor_runtime_config__.meteorRelease), _.extend(Meteor, {_get: function(a) {
        for (var b = 1; b < arguments.length; b++) {
            if (!(arguments[b] in a))
                return void 0;
            a = a[arguments[b]]
        }
        return a
    },_ensure: function(a) {
        for (var b = 1; b < arguments.length; b++) {
            var c = arguments[b];
            c in a || (a[c] = {}), a = a[c]
        }
        return a
    },_delete: function(a) {
        for (var b = [a], c = !0, d = 1; d < arguments.length - 1; d++) {
            var e = arguments[d];
            if (!(e in a)) {
                c = !1;
                break
            }
            if (a = a[e], "object" != typeof a)
                break;
            b.push(a)
        }
        for (var d = b.length - 1; d >= 0; d--) {
            var e = arguments[d + 1];
            if (c)
                c = !1;
            else
                for (var f in b[d][e])
                    return;
            delete b[d][e]
        }
    }}), _.extend(Meteor, {setTimeout: function(a, b) {
        if (Meteor._CurrentInvocation) {
            if (Meteor._CurrentInvocation.get() && Meteor._CurrentInvocation.get().isSimulation)
                throw new Error("Can't set timers inside simulations");
            var c = a;
            a = function() {
                Meteor._CurrentInvocation.withValue(null, c)
            }
        }
        return setTimeout(Meteor.bindEnvironment(a, function(a) {
            Meteor._debug("Exception from setTimeout callback:", a.stack)
        }), b)
    },setInterval: function(a, b) {
        if (Meteor._CurrentInvocation) {
            if (Meteor._CurrentInvocation.get() && Meteor._CurrentInvocation.get().isSimulation)
                throw new Error("Can't set timers inside simulations");
            var c = a;
            a = function() {
                Meteor._CurrentInvocation.withValue(null, c)
            }
        }
        return setInterval(Meteor.bindEnvironment(a, function(a) {
            Meteor._debug("Exception from setInterval callback:", a)
        }), b)
    },clearInterval: function(a) {
        return clearInterval(a)
    },clearTimeout: function(a) {
        return clearTimeout(a)
    },defer: function(a) {
        Meteor.setTimeout(function() {
            a()
        }, 0)
    }});
var inherits = function(a, b) {
    var c = function() {
    };
    c.prototype = b.prototype, a.prototype = new c, a.prototype.constructor = a
};
Meteor.makeErrorType = function(a, b) {
    var c = function() {
        var d = this;
        if (Error.captureStackTrace)
            Error.captureStackTrace(d, c);
        else {
            var e = new Error;
            e.__proto__ = c.prototype, e instanceof c && (d = e)
        }
        return b.apply(d, arguments), d.errorType = a, d
    };
    return inherits(c, Error), c
}, Meteor._noYieldsAllowed = function(a) {
    return a()
}, Meteor._SynchronousQueue = function() {
    var a = this;
    a._tasks = [], a._running = !1
}, _.extend(Meteor._SynchronousQueue.prototype, {runTask: function(a) {
        var b = this;
        if (!b.safeToRunTask())
            throw new Error("Could not synchronously run a task from a running task");
        b._tasks.push(a);
        var c = b._tasks;
        b._tasks = [], b._running = !0;
        try {
            for (; !_.isEmpty(c); ) {
                var d = c.shift();
                try {
                    d()
                } catch (e) {
                    if (_.isEmpty(c))
                        throw e;
                    Meteor._debug("Exception in queued task: " + e.stack)
                }
            }
        }finally {
            b._running = !1
        }
    },queueTask: function(a) {
        var b = this, c = _.isEmpty(b._tasks);
        b._tasks.push(a), c && setTimeout(_.bind(b.flush, b), 0)
    },flush: function() {
        var a = this;
        a.runTask(function() {
        })
    },drain: function() {
        var a = this;
        if (a.safeToRunTask())
            for (; !_.isEmpty(a._tasks); )
                a.flush()
    },safeToRunTask: function() {
        var a = this;
        return !a._running
    }});
var nextSlot = 0, currentValues = [];
Meteor.EnvironmentVariable = function() {
    this.slot = nextSlot++
}, _.extend(Meteor.EnvironmentVariable.prototype, {get: function() {
        return currentValues[this.slot]
    },withValue: function(a, b) {
        var c = currentValues[this.slot];
        try {
            currentValues[this.slot] = a;
            var d = b()
        }finally {
            currentValues[this.slot] = c
        }
        return d
    }}), Meteor.bindEnvironment = function(a, b, c) {
    var d = _.clone(currentValues);
    if (!b)
        throw new Error("onException must be supplied");
    return function() {
        var e = currentValues;
        try {
            currentValues = d;
            var f = a.apply(c, _.toArray(arguments))
        } catch (g) {
            b(g)
        }finally {
            currentValues = e
        }
        return f
    }
}, Deps = {}, Deps.active = !1, Deps.currentComputation = null;
var setCurrentComputation = function(a) {
    Deps.currentComputation = a, Deps.active = !!a
}, _debugFunc = function() {
    return "undefined" != typeof Meteor ? Meteor._debug : "undefined" != typeof console && console.log ? console.log : function() {
    }
}, nextId = 1, pendingComputations = [], willFlush = !1, inFlush = !1, inCompute = !1, afterFlushCallbacks = [], requireFlush = function() {
    willFlush || (setTimeout(Deps.flush, 0), willFlush = !0)
}, constructingComputation = !1;
Deps.Computation = function(a, b) {
    if (!constructingComputation)
        throw new Error("Deps.Computation constructor is private; use Deps.autorun");
    constructingComputation = !1;
    var c = this;
    c.stopped = !1, c.invalidated = !1, c.firstRun = !0, c._id = nextId++, c._onInvalidateCallbacks = [], c._parent = b, c._func = a, c._recomputing = !1;
    var d = !0;
    try {
        c._compute(), d = !1
    }finally {
        c.firstRun = !1, d && c.stop()
    }
}, _.extend(Deps.Computation.prototype, {onInvalidate: function(a) {
        var b = this;
        if ("function" != typeof a)
            throw new Error("onInvalidate requires a function");
        var c = function() {
            Deps.nonreactive(function() {
                a(b)
            })
        };
        b.invalidated ? c() : b._onInvalidateCallbacks.push(c)
    },invalidate: function() {
        var a = this;
        if (!a.invalidated) {
            a._recomputing || a.stopped || (requireFlush(), pendingComputations.push(this)), a.invalidated = !0;
            for (var b, c = 0; b = a._onInvalidateCallbacks[c]; c++)
                b();
            a._onInvalidateCallbacks = []
        }
    },stop: function() {
        this.stopped || (this.stopped = !0, this.invalidate())
    },_compute: function() {
        var a = this;
        a.invalidated = !1;
        var b = Deps.currentComputation;
        setCurrentComputation(a), inCompute = !0;
        try {
            a._func(a)
        }finally {
            setCurrentComputation(b), inCompute = !1
        }
    },_recompute: function() {
        var a = this;
        for (a._recomputing = !0; a.invalidated && !a.stopped; )
            try {
                a._compute()
            } catch (b) {
                _debugFunc()("Exception from Deps recompute:", b.stack || b.message)
            }
        a._recomputing = !1
    }}), Deps.Dependency = function() {
    this._dependentsById = {}
}, _.extend(Deps.Dependency.prototype, {depend: function(a) {
        if (!a) {
            if (!Deps.active)
                return !1;
            a = Deps.currentComputation
        }
        var b = this, c = a._id;
        return c in b._dependentsById ? !1 : (b._dependentsById[c] = a, a.onInvalidate(function() {
            delete b._dependentsById[c]
        }), !0)
    },changed: function() {
        var a = this;
        for (var b in a._dependentsById)
            a._dependentsById[b].invalidate()
    },hasDependents: function() {
        var a = this;
        for (var b in a._dependentsById)
            return !0;
        return !1
    }}), _.extend(Deps, {flush: function() {
        if (inFlush)
            throw new Error("Can't call Deps.flush while flushing");
        if (inCompute)
            throw new Error("Can't flush inside Deps.autorun");
        for (inFlush = !0, willFlush = !0; pendingComputations.length || afterFlushCallbacks.length; ) {
            var a = pendingComputations;
            pendingComputations = [];
            for (var b, c = 0; b = a[c]; c++)
                b._recompute();
            if (afterFlushCallbacks.length) {
                var d = afterFlushCallbacks.shift();
                try {
                    d()
                } catch (e) {
                    _debugFunc()("Exception from Deps afterFlush function:", e.stack || e.message)
                }
            }
        }
        inFlush = !1, willFlush = !1
    },autorun: function(a) {
        if ("function" != typeof a)
            throw new Error("Deps.autorun requires a function argument");
        constructingComputation = !0;
        var b = new Deps.Computation(a, Deps.currentComputation);
        return Deps.active && Deps.onInvalidate(function() {
            b.stop()
        }), b
    },nonreactive: function(a) {
        var b = Deps.currentComputation;
        setCurrentComputation(null);
        try {
            return a()
        }finally {
            setCurrentComputation(b)
        }
    },_makeNonreactive: function(a) {
        if (a.$isNonreactive)
            return a;
        var b = function() {
            var b, c = this, d = _.toArray(arguments);
            return Deps.nonreactive(function() {
                b = a.apply(c, d)
            }), b
        };
        return b.$isNonreactive = !0, b
    },onInvalidate: function(a) {
        if (!Deps.active)
            throw new Error("Deps.onInvalidate requires a currentComputation");
        Deps.currentComputation.onInvalidate(a)
    },afterFlush: function(a) {
        afterFlushCallbacks.push(a), requireFlush()
    }});
var stringify = function(a) {
    return void 0 === a ? "undefined" : EJSON.stringify(a)
}, parse = function(a) {
    return void 0 === a || "undefined" === a ? void 0 : EJSON.parse(a)
};
ReactiveDict = function(a) {
    this.keys = a || {}, this.keyDeps = {}, this.keyValueDeps = {}
}, _.extend(ReactiveDict.prototype, {set: function(a, b) {
        var c = this;
        b = stringify(b);
        var d = "undefined";
        if (_.has(c.keys, a) && (d = c.keys[a]), b !== d) {
            c.keys[a] = b;
            var e = function(a) {
                a && a.changed()
            };
            e(c.keyDeps[a]), c.keyValueDeps[a] && (e(c.keyValueDeps[a][d]), e(c.keyValueDeps[a][b]))
        }
    },setDefault: function(a, b) {
        var c = this;
        void 0 === c.keys[a] && c.set(a, b)
    },get: function(a) {
        var b = this;
        return b._ensureKey(a), b.keyDeps[a].depend(), parse(b.keys[a])
    },equals: function(a, b) {
        var c = this;
        if (!("string" == typeof b || "number" == typeof b || "boolean" == typeof b || "undefined" == typeof b || b instanceof Date || "undefined" != typeof Meteor.Collection && b instanceof Meteor.Collection.ObjectID || null === b))
            throw new Error("ReactiveDict.equals: value must be scalar");
        var d = stringify(b);
        if (Deps.active) {
            c._ensureKey(a), _.has(c.keyValueDeps[a], d) || (c.keyValueDeps[a][d] = new Deps.Dependency);
            var e = c.keyValueDeps[a][d].depend();
            e && Deps.onInvalidate(function() {
                c.keyValueDeps[a][d].hasDependents() || delete c.keyValueDeps[a][d]
            })
        }
        var f = void 0;
        return _.has(c.keys, a) && (f = parse(c.keys[a])), EJSON.equals(f, b)
    },_ensureKey: function(a) {
        var b = this;
        a in b.keyDeps || (b.keyDeps[a] = new Deps.Dependency, b.keyValueDeps[a] = {})
    },getMigrationData: function() {
        return this.keys
    }});
var migratedKeys = {};
if (Meteor._reload) {
    var migrationData = Meteor._reload.migrationData("session");
    migrationData && migrationData.keys && (migratedKeys = migrationData.keys)
}
Session = new ReactiveDict(migratedKeys), Meteor._reload && Meteor._reload.onMigrate("session", function() {
    return [!0, {keys: Session.keys}]
}), Random = {}, Random._Alea = function() {
    function a() {
        var a = 4022871197, b = function(b) {
            b = b.toString();
            for (var c = 0; c < b.length; c++) {
                a += b.charCodeAt(c);
                var d = .02519603282416938 * a;
                a = d >>> 0, d -= a, d *= a, a = d >>> 0, d -= a, a += 4294967296 * d
            }
            return 2.3283064365386963e-10 * (a >>> 0)
        };
        return b.version = "Mash 0.9", b
    }
    return function(b) {
        var c = 0, d = 0, e = 0, f = 1;
        0 == b.length && (b = [+new Date]);
        var g = a();
        c = g(" "), d = g(" "), e = g(" ");
        for (var h = 0; h < b.length; h++)
            c -= g(b[h]), 0 > c && (c += 1), d -= g(b[h]), 0 > d && (d += 1), e -= g(b[h]), 0 > e && (e += 1);
        g = null;
        var i = function() {
            var a = 2091639 * c + 2.3283064365386963e-10 * f;
            return c = d, d = e, e = a - (f = 0 | a)
        };
        return i.uint32 = function() {
            return 4294967296 * i()
        }, i.fract53 = function() {
            return i() + 1.1102230246251565e-16 * (0 | 2097152 * i())
        }, i.version = "Alea 0.9", i.args = b, i
    }(Array.prototype.slice.call(arguments))
};
var height = "undefined" != typeof window && window.innerHeight || "undefined" != typeof document && document.documentElement && document.documentElement.clientHeight || "undefined" != typeof document && document.body && document.body.clientHeight || 1, width = "undefined" != typeof window && window.innerWidth || "undefined" != typeof document && document.documentElement && document.documentElement.clientWidth || "undefined" != typeof document && document.body && document.body.clientWidth || 1, agent = "undefined" != typeof navigator && navigator.userAgent || "", pid = "undefined" != typeof process && process.pid || 1;
Random.fraction = new Random._Alea([new Date, height, width, agent, pid, Math.random()]), Random.choice = function(a) {
    var b = Math.floor(Random.fraction() * a.length);
    return "string" == typeof a ? a.substr(b, 1) : a[b]
};
var UNMISTAKABLE_CHARS = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";
Random.id = function() {
    for (var a = [], b = 0; 17 > b; b++)
        a[b] = Random.choice(UNMISTAKABLE_CHARS);
    return a.join("")
};
var HEX_DIGITS = "0123456789abcdef";
Random.hexString = function(a) {
    for (var b = [], c = 0; a > c; ++c)
        b.push(Random.choice("0123456789abcdef"));
    return b.join("")
}, EJSON = {};
var customTypes = {};
EJSON.addType = function(a, b) {
    if (_.has(customTypes, a))
        throw new Error("Type " + a + " already present");
    customTypes[a] = b
};
var builtinConverters = [{matchJSONValue: function(a) {
            return _.has(a, "$date") && 1 === _.size(a)
        },matchObject: function(a) {
            return a instanceof Date
        },toJSONValue: function(a) {
            return {$date: a.getTime()}
        },fromJSONValue: function(a) {
            return new Date(a.$date)
        }}, {matchJSONValue: function(a) {
            return _.has(a, "$binary") && 1 === _.size(a)
        },matchObject: function(a) {
            return "undefined" != typeof Uint8Array && a instanceof Uint8Array || a && _.has(a, "$Uint8ArrayPolyfill")
        },toJSONValue: function(a) {
            return {$binary: EJSON._base64Encode(a)}
        },fromJSONValue: function(a) {
            return EJSON._base64Decode(a.$binary)
        }}, {matchJSONValue: function(a) {
            return _.has(a, "$escape") && 1 === _.size(a)
        },matchObject: function(a) {
            return _.isEmpty(a) || _.size(a) > 2 ? !1 : _.any(builtinConverters, function(b) {
                return b.matchJSONValue(a)
            })
        },toJSONValue: function(a) {
            var b = {};
            return _.each(a, function(a, c) {
                b[c] = EJSON.toJSONValue(a)
            }), {$escape: b}
        },fromJSONValue: function(a) {
            var b = {};
            return _.each(a.$escape, function(a, c) {
                b[c] = EJSON.fromJSONValue(a)
            }), b
        }}, {matchJSONValue: function(a) {
            return _.has(a, "$type") && _.has(a, "$value") && 2 === _.size(a)
        },matchObject: function(a) {
            return EJSON._isCustomType(a)
        },toJSONValue: function(a) {
            return {$type: a.typeName(),$value: a.toJSONValue()}
        },fromJSONValue: function(a) {
            var b = a.$type, c = customTypes[b];
            return c(a.$value)
        }}];
EJSON._isCustomType = function(a) {
    return a && "function" == typeof a.toJSONValue && "function" == typeof a.typeName && _.has(customTypes, a.typeName())
};
var adjustTypesToJSONValue = EJSON._adjustTypesToJSONValue = function(a) {
    if (null === a)
        return null;
    var b = toJSONValueHelper(a);
    return void 0 !== b ? b : (_.each(a, function(b, c) {
        if ("object" == typeof b || void 0 === b) {
            var d = toJSONValueHelper(b);
            return d ? (a[c] = d, void 0) : (adjustTypesToJSONValue(b), void 0)
        }
    }), a)
}, toJSONValueHelper = function(a) {
    for (var b = 0; b < builtinConverters.length; b++) {
        var c = builtinConverters[b];
        if (c.matchObject(a))
            return c.toJSONValue(a)
    }
    return void 0
};
EJSON.toJSONValue = function(a) {
    var b = toJSONValueHelper(a);
    return void 0 !== b ? b : ("object" == typeof a && (a = EJSON.clone(a), adjustTypesToJSONValue(a)), a)
};
var adjustTypesFromJSONValue = EJSON._adjustTypesFromJSONValue = function(a) {
    if (null === a)
        return null;
    var b = fromJSONValueHelper(a);
    return b !== a ? b : (_.each(a, function(b, c) {
        if ("object" == typeof b) {
            var d = fromJSONValueHelper(b);
            if (b !== d)
                return a[c] = d, void 0;
            adjustTypesFromJSONValue(b)
        }
    }), a)
}, fromJSONValueHelper = function(a) {
    if ("object" == typeof a && null !== a && _.size(a) <= 2 && _.all(a, function(a, b) {
        return "string" == typeof b && "$" === b.substr(0, 1)
    }))
        for (var b = 0; b < builtinConverters.length; b++) {
            var c = builtinConverters[b];
            if (c.matchJSONValue(a))
                return c.fromJSONValue(a)
        }
    return a
};
EJSON.fromJSONValue = function(a) {
    var b = fromJSONValueHelper(a);
    return b === a && "object" == typeof a ? (a = EJSON.clone(a), adjustTypesFromJSONValue(a), a) : b
}, EJSON.stringify = function(a) {
    return JSON.stringify(EJSON.toJSONValue(a))
}, EJSON.parse = function(a) {
    return EJSON.fromJSONValue(JSON.parse(a))
}, EJSON.isBinary = function(a) {
    return "undefined" != typeof Uint8Array && a instanceof Uint8Array || a && a.$Uint8ArrayPolyfill
}, EJSON.equals = function(a, b, c) {
    var d, e = !(!c || !c.keyOrderSensitive);
    if (a === b)
        return !0;
    if (!a || !b)
        return !1;
    if ("object" != typeof a || "object" != typeof b)
        return !1;
    if (a instanceof Date && b instanceof Date)
        return a.valueOf() === b.valueOf();
    if (EJSON.isBinary(a) && EJSON.isBinary(b)) {
        if (a.length !== b.length)
            return !1;
        for (d = 0; d < a.length; d++)
            if (a[d] !== b[d])
                return !1;
        return !0
    }
    if ("function" == typeof a.equals)
        return a.equals(b, c);
    if (a instanceof Array) {
        if (!(b instanceof Array))
            return !1;
        if (a.length !== b.length)
            return !1;
        for (d = 0; d < a.length; d++)
            if (!EJSON.equals(a[d], b[d], c))
                return !1;
        return !0
    }
    var f;
    if (e) {
        var g = [];
        return _.each(b, function(a, b) {
            g.push(b)
        }), d = 0, f = _.all(a, function(a, e) {
            return d >= g.length ? !1 : e !== g[d] ? !1 : EJSON.equals(a, b[g[d]], c) ? (d++, !0) : !1
        }), f && d === g.length
    }
    return d = 0, f = _.all(a, function(a, e) {
        return _.has(b, e) ? EJSON.equals(a, b[e], c) ? (d++, !0) : !1 : !1
    }), f && _.size(b) === d
}, EJSON.clone = function(a) {
    var b;
    if ("object" != typeof a)
        return a;
    if (null === a)
        return null;
    if (a instanceof Date)
        return new Date(a.getTime());
    if (EJSON.isBinary(a)) {
        b = EJSON.newBinary(a.length);
        for (var c = 0; c < a.length; c++)
            b[c] = a[c];
        return b
    }
    if (_.isArray(a) || _.isArguments(a)) {
        for (b = [], c = 0; c < a.length; c++)
            b[c] = EJSON.clone(a[c]);
        return b
    }
    return "function" == typeof a.clone ? a.clone() : (b = {}, _.each(a, function(a, c) {
        b[c] = EJSON.clone(a)
    }), b)
};
var JSON;
JSON || (JSON = {}), function() {
    function str(a, b) {
        var c, d, e, f, g, h = gap, i = b[a];
        switch (i && "object" == typeof i && "function" == typeof i.toJSON && (i = i.toJSON(a)), "function" == typeof rep && (i = rep.call(b, a, i)), typeof i) {
            case "string":
                return quote(i);
            case "number":
                return isFinite(i) ? String(i) : "null";
            case "boolean":
            case "null":
                return String(i);
            case "object":
                if (!i)
                    return "null";
                if (gap += indent, g = [], "[object Array]" === Object.prototype.toString.apply(i)) {
                    for (f = i.length, c = 0; f > c; c += 1)
                        g[c] = str(c, i) || "null";
                    return e = 0 === g.length ? "[]" : gap ? "[\n" + gap + g.join(",\n" + gap) + "\n" + h + "]" : "[" + g.join(",") + "]", gap = h, e
                }
                if (rep && "object" == typeof rep)
                    for (f = rep.length, c = 0; f > c; c += 1)
                        "string" == typeof rep[c] && (d = rep[c], e = str(d, i), e && g.push(quote(d) + (gap ? ": " : ":") + e));
                else
                    for (d in i)
                        Object.prototype.hasOwnProperty.call(i, d) && (e = str(d, i), e && g.push(quote(d) + (gap ? ": " : ":") + e));
                return e = 0 === g.length ? "{}" : gap ? "{\n" + gap + g.join(",\n" + gap) + "\n" + h + "}" : "{" + g.join(",") + "}", gap = h, e
        }
    }
    function quote(a) {
        return escapable.lastIndex = 0, escapable.test(a) ? '"' + a.replace(escapable, function(a) {
            var b = meta[a];
            return "string" == typeof b ? b : "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4)
        }) + '"' : '"' + a + '"'
    }
    function f(a) {
        return 10 > a ? "0" + a : a
    }
    "function" != typeof Date.prototype.toJSON && (Date.prototype.toJSON = function() {
        return isFinite(this.valueOf()) ? this.getUTCFullYear() + "-" + f(this.getUTCMonth() + 1) + "-" + f(this.getUTCDate()) + "T" + f(this.getUTCHours()) + ":" + f(this.getUTCMinutes()) + ":" + f(this.getUTCSeconds()) + "Z" : null
    }, String.prototype.toJSON = Number.prototype.toJSON = Boolean.prototype.toJSON = function() {
        return this.valueOf()
    });
    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, gap, indent, meta = {"\b": "\\b","	": "\\t","\n": "\\n","\f": "\\f","\r": "\\r",'"': '\\"',"\\": "\\\\"}, rep;
    "function" != typeof JSON.stringify && (JSON.stringify = function(a, b, c) {
        var d;
        if (gap = "", indent = "", "number" == typeof c)
            for (d = 0; c > d; d += 1)
                indent += " ";
        else
            "string" == typeof c && (indent = c);
        if (rep = b, !b || "function" == typeof b || "object" == typeof b && "number" == typeof b.length)
            return str("", {"": a});
        throw new Error("JSON.stringify")
    }), "function" != typeof JSON.parse && (JSON.parse = function(text, reviver) {
        function walk(a, b) {
            var c, d, e = a[b];
            if (e && "object" == typeof e)
                for (c in e)
                    Object.prototype.hasOwnProperty.call(e, c) && (d = walk(e, c), void 0 !== d ? e[c] = d : delete e[c]);
            return reviver.call(a, b, e)
        }
        var j;
        if (text = String(text), cx.lastIndex = 0, cx.test(text) && (text = text.replace(cx, function(a) {
            return "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4)
        })), /^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]").replace(/(?:^|:|,)(?:\s*\[)+/g, "")))
            return j = eval("(" + text + ")"), "function" == typeof reviver ? walk({"": j}, "") : j;
        throw new SyntaxError("JSON.parse")
    })
}(), SockJS = function() {
    var a = document, b = window, c = {}, d = function() {
    };
    d.prototype.addEventListener = function(a, b) {
        this._listeners || (this._listeners = {}), a in this._listeners || (this._listeners[a] = []);
        var d = this._listeners[a];
        -1 === c.arrIndexOf(d, b) && d.push(b)
    }, d.prototype.removeEventListener = function(a, b) {
        if (this._listeners && a in this._listeners) {
            var d = this._listeners[a], e = c.arrIndexOf(d, b);
            return -1 !== e ? (d.length > 1 ? this._listeners[a] = d.slice(0, e).concat(d.slice(e + 1)) : delete this._listeners[a], void 0) : void 0
        }
    }, d.prototype.dispatchEvent = function(a) {
        var b = a.type, c = Array.prototype.slice.call(arguments, 0);
        if (this["on" + b] && this["on" + b].apply(this, c), this._listeners && b in this._listeners)
            for (var d = 0; d < this._listeners[b].length; d++)
                this._listeners[b][d].apply(this, c)
    };
    var e = function(a, b) {
        if (this.type = a, "undefined" != typeof b)
            for (var c in b)
                b.hasOwnProperty(c) && (this[c] = b[c])
    };
    e.prototype.toString = function() {
        var a = [];
        for (var b in this)
            if (this.hasOwnProperty(b)) {
                var c = this[b];
                "function" == typeof c && (c = "[function]"), a.push(b + "=" + c)
            }
        return "SimpleEvent(" + a.join(", ") + ")"
    };
    var f = function(a) {
        var b = this;
        b._events = a || [], b._listeners = {}
    };
    f.prototype.emit = function(a) {
        var b = this;
        if (b._verifyType(a), !b._nuked) {
            var c = Array.prototype.slice.call(arguments, 1);
            if (b["on" + a] && b["on" + a].apply(b, c), a in b._listeners)
                for (var d = 0; d < b._listeners[a].length; d++)
                    b._listeners[a][d].apply(b, c)
        }
    }, f.prototype.on = function(a, b) {
        var c = this;
        c._verifyType(a), c._nuked || (a in c._listeners || (c._listeners[a] = []), c._listeners[a].push(b))
    }, f.prototype._verifyType = function(a) {
        var b = this;
        -1 === c.arrIndexOf(b._events, a) && c.log("Event " + JSON.stringify(a) + " not listed " + JSON.stringify(b._events) + " in " + b)
    }, f.prototype.nuke = function() {
        var a = this;
        a._nuked = !0;
        for (var b = 0; b < a._events.length; b++)
            delete a[a._events[b]];
        a._listeners = {}
    };
    var g = "abcdefghijklmnopqrstuvwxyz0123456789_";
    c.random_string = function(a, b) {
        b = b || g.length;
        var c, d = [];
        for (c = 0; a > c; c++)
            d.push(g.substr(Math.floor(Math.random() * b), 1));
        return d.join("")
    }, c.random_number = function(a) {
        return Math.floor(Math.random() * a)
    }, c.random_number_string = function(a) {
        var b = ("" + (a - 1)).length, d = Array(b + 1).join("0");
        return (d + c.random_number(a)).slice(-b)
    }, c.getOrigin = function(a) {
        a += "/";
        var b = a.split("/").slice(0, 3);
        return b.join("/")
    }, c.isSameOriginUrl = function(a, c) {
        return c || (c = b.location.href), a.split("/").slice(0, 3).join("/") === c.split("/").slice(0, 3).join("/")
    }, c.isSameOriginScheme = function(a, c) {
        return c || (c = b.location.href), a.split(":")[0] === c.split(":")[0]
    }, c.getParentDomain = function(a) {
        if (/^[0-9.]*$/.test(a))
            return a;
        if (/^\[/.test(a))
            return a;
        if (!/[.]/.test(a))
            return a;
        var b = a.split(".").slice(1);
        return b.join(".")
    }, c.objectExtend = function(a, b) {
        for (var c in b)
            b.hasOwnProperty(c) && (a[c] = b[c]);
        return a
    };
    var h = "_jp";
    c.polluteGlobalNamespace = function() {
        h in b || (b[h] = {})
    }, c.closeFrame = function(a, b) {
        return "c" + JSON.stringify([a, b])
    }, c.userSetCode = function(a) {
        return 1e3 === a || a >= 3e3 && 4999 >= a
    }, c.countRTO = function(a) {
        var b;
        return b = a > 100 ? 3 * a : a + 200
    }, c.log = function() {
        b.console && console.log && console.log.apply && console.log.apply(console, arguments)
    }, c.bind = function(a, b) {
        return a.bind ? a.bind(b) : function() {
            return a.apply(b, arguments)
        }
    }, c.flatUrl = function(a) {
        return -1 === a.indexOf("?") && -1 === a.indexOf("#")
    }, c.amendUrl = function(b) {
        var d = a.location;
        if (!b)
            throw new Error("Wrong url for SockJS");
        if (!c.flatUrl(b))
            throw new Error("Only basic urls are supported in SockJS");
        return 0 === b.indexOf("//") && (b = d.protocol + b), 0 === b.indexOf("/") && (b = d.protocol + "//" + d.host + b), b = b.replace(/[/]+$/, "")
    }, c.arrIndexOf = function(a, b) {
        for (var c = 0; c < a.length; c++)
            if (a[c] === b)
                return c;
        return -1
    }, c.arrSkip = function(a, b) {
        var d = c.arrIndexOf(a, b);
        if (-1 === d)
            return a.slice();
        var e = a.slice(0, d);
        return e.concat(a.slice(d + 1))
    }, c.isArray = Array.isArray || function(a) {
        return {}.toString.call(a).indexOf("Array") >= 0
    }, c.delay = function(a, b) {
        return "function" == typeof a && (b = a, a = 0), setTimeout(b, a)
    };
    var i, j = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, k = {"\0": "\\u0000","": "\\u0001","": "\\u0002","": "\\u0003","": "\\u0004","": "\\u0005","": "\\u0006","": "\\u0007","\b": "\\b","	": "\\t","\n": "\\n","": "\\u000b","\f": "\\f","\r": "\\r","": "\\u000e","": "\\u000f","": "\\u0010","": "\\u0011","": "\\u0012","": "\\u0013","": "\\u0014","": "\\u0015","": "\\u0016","": "\\u0017","": "\\u0018","": "\\u0019","": "\\u001a","": "\\u001b","": "\\u001c","": "\\u001d","": "\\u001e","": "\\u001f",'"': '\\"',"\\": "\\\\","": "\\u007f","": "\\u0080","": "\\u0081","": "\\u0082","": "\\u0083","": "\\u0084","": "\\u0085","": "\\u0086","": "\\u0087","": "\\u0088","": "\\u0089","": "\\u008a","": "\\u008b","": "\\u008c","": "\\u008d","": "\\u008e","": "\\u008f","": "\\u0090","": "\\u0091","": "\\u0092","": "\\u0093","": "\\u0094","": "\\u0095","": "\\u0096","": "\\u0097","": "\\u0098","": "\\u0099","": "\\u009a","": "\\u009b","": "\\u009c","": "\\u009d","": "\\u009e","": "\\u009f","­": "\\u00ad","؀": "\\u0600","؁": "\\u0601","؂": "\\u0602","؃": "\\u0603","؄": "\\u0604","܏": "\\u070f","឴": "\\u17b4","឵": "\\u17b5","‌": "\\u200c","‍": "\\u200d","‎": "\\u200e","‏": "\\u200f","\u2028": "\\u2028","\u2029": "\\u2029","‪": "\\u202a","‫": "\\u202b","‬": "\\u202c","‭": "\\u202d","‮": "\\u202e"," ": "\\u202f","⁠": "\\u2060","⁡": "\\u2061","⁢": "\\u2062","⁣": "\\u2063","⁤": "\\u2064","⁥": "\\u2065","⁦": "\\u2066","⁧": "\\u2067","⁨": "\\u2068","⁩": "\\u2069","⁪": "\\u206a","⁫": "\\u206b","⁬": "\\u206c","⁭": "\\u206d","⁮": "\\u206e","⁯": "\\u206f","﻿": "\\ufeff","￰": "\\ufff0","￱": "\\ufff1","￲": "\\ufff2","￳": "\\ufff3","￴": "\\ufff4","￵": "\\ufff5","￶": "\\ufff6","￷": "\\ufff7","￸": "\\ufff8","￹": "\\ufff9","￺": "\\ufffa","￻": "\\ufffb","￼": "\\ufffc","�": "\\ufffd","￾": "\\ufffe","￿": "\\uffff"}, l = /[\x00-\x1f\ud800-\udfff\ufffe\uffff\u0300-\u0333\u033d-\u0346\u034a-\u034c\u0350-\u0352\u0357-\u0358\u035c-\u0362\u0374\u037e\u0387\u0591-\u05af\u05c4\u0610-\u0617\u0653-\u0654\u0657-\u065b\u065d-\u065e\u06df-\u06e2\u06eb-\u06ec\u0730\u0732-\u0733\u0735-\u0736\u073a\u073d\u073f-\u0741\u0743\u0745\u0747\u07eb-\u07f1\u0951\u0958-\u095f\u09dc-\u09dd\u09df\u0a33\u0a36\u0a59-\u0a5b\u0a5e\u0b5c-\u0b5d\u0e38-\u0e39\u0f43\u0f4d\u0f52\u0f57\u0f5c\u0f69\u0f72-\u0f76\u0f78\u0f80-\u0f83\u0f93\u0f9d\u0fa2\u0fa7\u0fac\u0fb9\u1939-\u193a\u1a17\u1b6b\u1cda-\u1cdb\u1dc0-\u1dcf\u1dfc\u1dfe\u1f71\u1f73\u1f75\u1f77\u1f79\u1f7b\u1f7d\u1fbb\u1fbe\u1fc9\u1fcb\u1fd3\u1fdb\u1fe3\u1feb\u1fee-\u1fef\u1ff9\u1ffb\u1ffd\u2000-\u2001\u20d0-\u20d1\u20d4-\u20d7\u20e7-\u20e9\u2126\u212a-\u212b\u2329-\u232a\u2adc\u302b-\u302c\uaab2-\uaab3\uf900-\ufa0d\ufa10\ufa12\ufa15-\ufa1e\ufa20\ufa22\ufa25-\ufa26\ufa2a-\ufa2d\ufa30-\ufa6d\ufa70-\ufad9\ufb1d\ufb1f\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40-\ufb41\ufb43-\ufb44\ufb46-\ufb4e\ufff0-\uffff]/g, m = JSON && JSON.stringify || function(a) {
        return j.lastIndex = 0, j.test(a) && (a = a.replace(j, function(a) {
            return k[a]
        })), '"' + a + '"'
    }, n = function(a) {
        var b, c = {}, d = [];
        for (b = 0; 65536 > b; b++)
            d.push(String.fromCharCode(b));
        return a.lastIndex = 0, d.join("").replace(a, function(a) {
            return c[a] = "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4), ""
        }), a.lastIndex = 0, c
    };
    c.quote = function(a) {
        var b = m(a);
        return l.lastIndex = 0, l.test(b) ? (i || (i = n(l)), b.replace(l, function(a) {
            return i[a]
        })) : b
    };
    var o = ["websocket", "xdr-streaming", "xhr-streaming", "iframe-eventsource", "iframe-htmlfile", "xdr-polling", "xhr-polling", "iframe-xhr-polling", "jsonp-polling"];
    c.probeProtocols = function() {
        for (var a = {}, b = 0; b < o.length; b++) {
            var c = o[b];
            a[c] = y[c] && y[c].enabled()
        }
        return a
    }, c.detectProtocols = function(a, b, c) {
        var d = {}, e = [];
        b || (b = o);
        for (var f = 0; f < b.length; f++) {
            var g = b[f];
            d[g] = a[g]
        }
        var h = function(a) {
            var b = a.shift();
            d[b] ? e.push(b) : a.length > 0 && h(a)
        };
        return c.websocket !== !1 && h(["websocket"]), d["xhr-streaming"] && !c.null_origin ? e.push("xhr-streaming") : !d["xdr-streaming"] || c.cookie_needed || c.null_origin ? h(["iframe-eventsource", "iframe-htmlfile"]) : e.push("xdr-streaming"), d["xhr-polling"] && !c.null_origin ? e.push("xhr-polling") : !d["xdr-polling"] || c.cookie_needed || c.null_origin ? h(["iframe-xhr-polling", "jsonp-polling"]) : e.push("xdr-polling"), e
    };
    var p = "_sockjs_global";
    c.createHook = function() {
        var a = "a" + c.random_string(8);
        if (!(p in b)) {
            var d = {};
            b[p] = function(a) {
                return a in d || (d[a] = {id: a,del: function() {
                        delete d[a]
                    }}), d[a]
            }
        }
        return b[p](a)
    }, c.attachMessage = function(a) {
        c.attachEvent("message", a)
    }, c.attachEvent = function(c, d) {
        "undefined" != typeof b.addEventListener ? b.addEventListener(c, d, !1) : (a.attachEvent("on" + c, d), b.attachEvent("on" + c, d))
    }, c.detachMessage = function(a) {
        c.detachEvent("message", a)
    }, c.detachEvent = function(c, d) {
        "undefined" != typeof b.addEventListener ? b.removeEventListener(c, d, !1) : (a.detachEvent("on" + c, d), b.detachEvent("on" + c, d))
    };
    var q = {}, r = !1, s = function() {
        for (var a in q)
            q[a](), delete q[a]
    }, t = function() {
        r || (r = !0, s())
    };
    c.attachEvent("unload", t), c.unload_add = function(a) {
        var b = c.random_string(8);
        return q[b] = a, r && c.delay(s), b
    }, c.unload_del = function(a) {
        a in q && delete q[a]
    }, c.createIframe = function(b, d) {
        var e, f, g = a.createElement("iframe"), h = function() {
            clearTimeout(e);
            try {
                g.onload = null
            } catch (a) {
            }
            g.onerror = null
        }, i = function() {
            g && (h(), setTimeout(function() {
                g && g.parentNode.removeChild(g), g = null
            }, 0), c.unload_del(f))
        }, j = function(a) {
            g && (i(), d(a))
        }, k = function(a, b) {
            try {
                g && g.contentWindow && g.contentWindow.postMessage(a, b)
            } catch (c) {
            }
        };
        return g.src = b, g.style.display = "none", g.style.position = "absolute", g.onerror = function() {
            j("onerror")
        }, g.onload = function() {
            clearTimeout(e), e = setTimeout(function() {
                j("onload timeout")
            }, 2e3)
        }, a.body.appendChild(g), e = setTimeout(function() {
            j("timeout")
        }, 15e3), f = c.unload_add(i), {post: k,cleanup: i,loaded: h}
    }, c.createHtmlfile = function(a, d) {
        var e, f, g, i = new ActiveXObject("htmlfile"), j = function() {
            clearTimeout(e)
        }, k = function() {
            i && (j(), c.unload_del(f), g.parentNode.removeChild(g), g = i = null, CollectGarbage())
        }, l = function(a) {
            i && (k(), d(a))
        }, m = function(a, b) {
            try {
                g && g.contentWindow && g.contentWindow.postMessage(a, b)
            } catch (c) {
            }
        };
        i.open(), i.write('<html><script>document.domain="' + document.domain + '";' + "</s" + "cript></html>"), i.close(), i.parentWindow[h] = b[h];
        var n = i.createElement("div");
        return i.body.appendChild(n), g = i.createElement("iframe"), n.appendChild(g), g.src = a, e = setTimeout(function() {
            l("timeout")
        }, 15e3), f = c.unload_add(k), {post: m,cleanup: k,loaded: j}
    };
    var u = function() {
    };
    u.prototype = new f(["chunk", "finish"]), u.prototype._start = function(a, d, e, f) {
        var g = this;
        try {
            g.xhr = new XMLHttpRequest
        } catch (h) {
        }
        if (!g.xhr)
            try {
                g.xhr = new b.ActiveXObject("Microsoft.XMLHTTP")
            } catch (h) {
            }
        (b.ActiveXObject || b.XDomainRequest) && (d += (-1 === d.indexOf("?") ? "?" : "&") + "t=" + +new Date), g.unload_ref = c.unload_add(function() {
            g._cleanup(!0)
        });
        try {
            g.xhr.open(a, d, !0)
        } catch (i) {
            return g.emit("finish", 0, ""), g._cleanup(), void 0
        }
        if (f && f.no_credentials || (g.xhr.withCredentials = "true"), f && f.headers)
            for (var j in f.headers)
                g.xhr.setRequestHeader(j, f.headers[j]);
        g.xhr.onreadystatechange = function() {
            if (g.xhr) {
                var a = g.xhr;
                switch (a.readyState) {
                    case 3:
                        try {
                            var b = a.status, c = a.responseText
                        } catch (a) {
                        }
                        1223 === b && (b = 204), c && c.length > 0 && g.emit("chunk", b, c);
                        break;
                    case 4:
                        var b = a.status;
                        1223 === b && (b = 204), g.emit("finish", b, a.responseText), g._cleanup(!1)
                }
            }
        }, g.xhr.send(e)
    }, u.prototype._cleanup = function(a) {
        var b = this;
        if (b.xhr) {
            if (c.unload_del(b.unload_ref), b.xhr.onreadystatechange = function() {
            }, a)
                try {
                    b.xhr.abort()
                } catch (d) {
                }
            b.unload_ref = b.xhr = null
        }
    }, u.prototype.close = function() {
        var a = this;
        a.nuke(), a._cleanup(!0)
    };
    var v = c.XHRCorsObject = function() {
        var a = this, b = arguments;
        c.delay(function() {
            a._start.apply(a, b)
        })
    };
    v.prototype = new u;
    var w = c.XHRLocalObject = function(a, b, d) {
        var e = this;
        c.delay(function() {
            e._start(a, b, d, {no_credentials: !0})
        })
    };
    w.prototype = new u;
    var x = c.XDRObject = function(a, b, d) {
        var e = this;
        c.delay(function() {
            e._start(a, b, d)
        })
    };
    x.prototype = new f(["chunk", "finish"]), x.prototype._start = function(a, b, d) {
        var e = this, f = new XDomainRequest;
        b += (-1 === b.indexOf("?") ? "?" : "&") + "t=" + +new Date;
        var g = f.ontimeout = f.onerror = function() {
            e.emit("finish", 0, ""), e._cleanup(!1)
        };
        f.onprogress = function() {
            e.emit("chunk", 200, f.responseText)
        }, f.onload = function() {
            e.emit("finish", 200, f.responseText), e._cleanup(!1)
        }, e.xdr = f, e.unload_ref = c.unload_add(function() {
            e._cleanup(!0)
        });
        try {
            e.xdr.open(a, b), e.xdr.send(d)
        } catch (h) {
            g()
        }
    }, x.prototype._cleanup = function(a) {
        var b = this;
        if (b.xdr) {
            if (c.unload_del(b.unload_ref), b.xdr.ontimeout = b.xdr.onerror = b.xdr.onprogress = b.xdr.onload = null, a)
                try {
                    b.xdr.abort()
                } catch (d) {
                }
            b.unload_ref = b.xdr = null
        }
    }, x.prototype.close = function() {
        var a = this;
        a.nuke(), a._cleanup(!0)
    }, c.isXHRCorsCapable = function() {
        return b.XMLHttpRequest && "withCredentials" in new XMLHttpRequest ? 1 : b.XDomainRequest && a.domain ? 2 : L.enabled() ? 3 : 4
    };
    var y = function(a, d, e) {
        if (this === b)
            return new y(a, d, e);
        var f, g = this;
        g._options = {devel: !1,debug: !1,protocols_whitelist: [],info: void 0,rtt: void 0}, e && c.objectExtend(g._options, e), g._base_url = c.amendUrl(a), g._server = g._options.server || c.random_number_string(1e3), g._options.protocols_whitelist && g._options.protocols_whitelist.length ? f = g._options.protocols_whitelist : (f = "string" == typeof d && d.length > 0 ? [d] : c.isArray(d) ? d : null, f && g._debug('Deprecated API: Use "protocols_whitelist" option instead of supplying protocol list as a second parameter to SockJS constructor.')), g._protocols = [], g.protocol = null, g.readyState = y.CONNECTING, g._ir = S(g._base_url), g._ir.onfinish = function(a, b) {
            g._ir = null, a ? (g._options.info && (a = c.objectExtend(a, g._options.info)), g._options.rtt && (b = g._options.rtt), g._applyInfo(a, b, f), g._didClose()) : g._didClose(1002, "Can't connect to server", !0)
        }
    };
    y.prototype = new d, y.version = "0.3.4", y.CONNECTING = 0, y.OPEN = 1, y.CLOSING = 2, y.CLOSED = 3, y.prototype._debug = function() {
        this._options.debug && c.log.apply(c, arguments)
    }, y.prototype._dispatchOpen = function() {
        var a = this;
        a.readyState === y.CONNECTING ? (a._transport_tref && (clearTimeout(a._transport_tref), a._transport_tref = null), a.readyState = y.OPEN, a.dispatchEvent(new e("open"))) : a._didClose(1006, "Server lost session")
    }, y.prototype._dispatchMessage = function(a) {
        var b = this;
        b.readyState === y.OPEN && b.dispatchEvent(new e("message", {data: a}))
    }, y.prototype._dispatchHeartbeat = function() {
        var a = this;
        a.readyState === y.OPEN && a.dispatchEvent(new e("heartbeat", {}))
    }, y.prototype._didClose = function(a, b, d) {
        var f = this;
        if (f.readyState !== y.CONNECTING && f.readyState !== y.OPEN && f.readyState !== y.CLOSING)
            throw new Error("INVALID_STATE_ERR");
        f._ir && (f._ir.nuke(), f._ir = null), f._transport && (f._transport.doCleanup(), f._transport = null);
        var g = new e("close", {code: a,reason: b,wasClean: c.userSetCode(a)});
        if (!c.userSetCode(a) && f.readyState === y.CONNECTING && !d) {
            if (f._try_next_protocol(g))
                return;
            g = new e("close", {code: 2e3,reason: "All transports failed",wasClean: !1,last_event: g})
        }
        f.readyState = y.CLOSED, c.delay(function() {
            f.dispatchEvent(g)
        })
    }, y.prototype._didMessage = function(a) {
        var b = this, c = a.slice(0, 1);
        switch (c) {
            case "o":
                b._dispatchOpen();
                break;
            case "a":
                for (var d = JSON.parse(a.slice(1) || "[]"), e = 0; e < d.length; e++)
                    b._dispatchMessage(d[e]);
                break;
            case "m":
                var d = JSON.parse(a.slice(1) || "null");
                b._dispatchMessage(d);
                break;
            case "c":
                var d = JSON.parse(a.slice(1) || "[]");
                b._didClose(d[0], d[1]);
                break;
            case "h":
                b._dispatchHeartbeat()
        }
    }, y.prototype._try_next_protocol = function(b) {
        var d = this;
        for (d.protocol && (d._debug("Closed transport:", d.protocol, "" + b), d.protocol = null), d._transport_tref && (clearTimeout(d._transport_tref), d._transport_tref = null); ; ) {
            var e = d.protocol = d._protocols.shift();
            if (!e)
                return !1;
            if (y[e] && y[e].need_body === !0 && (!a.body || "undefined" != typeof a.readyState && "complete" !== a.readyState))
                return d._protocols.unshift(e), d.protocol = "waiting-for-load", c.attachEvent("load", function() {
                    d._try_next_protocol()
                }), !0;
            if (y[e] && y[e].enabled(d._options)) {
                var f = y[e].roundTrips || 1, g = (d._options.rto || 0) * f || 5e3;
                d._transport_tref = c.delay(g, function() {
                    d.readyState === y.CONNECTING && d._didClose(2007, "Transport timeouted")
                });
                var h = c.random_string(8), i = d._base_url + "/" + d._server + "/" + h;
                return d._debug("Opening transport:", e, " url:" + i, " RTO:" + d._options.rto), d._transport = new y[e](d, i, d._base_url), !0
            }
            d._debug("Skipping transport:", e)
        }
    }, y.prototype.close = function(a, b) {
        var d = this;
        if (a && !c.userSetCode(a))
            throw new Error("INVALID_ACCESS_ERR");
        return d.readyState !== y.CONNECTING && d.readyState !== y.OPEN ? !1 : (d.readyState = y.CLOSING, d._didClose(a || 1e3, b || "Normal closure"), !0)
    }, y.prototype.send = function(a) {
        var b = this;
        if (b.readyState === y.CONNECTING)
            throw new Error("INVALID_STATE_ERR");
        return b.readyState === y.OPEN && b._transport.doSend(c.quote("" + a)), !0
    }, y.prototype._applyInfo = function(b, d, e) {
        var f = this;
        f._options.info = b, f._options.rtt = d, f._options.rto = c.countRTO(d), f._options.info.null_origin = !a.domain;
        var g = c.probeProtocols();
        f._protocols = c.detectProtocols(g, e, b), c.isSameOriginScheme(f._base_url) || 2 !== c.isXHRCorsCapable() || (f._protocols = ["jsonp-polling"])
    };
    var z = y.websocket = function(a, d) {
        var e = this, f = d + "/websocket";
        f = "https" === f.slice(0, 5) ? "wss" + f.slice(5) : "ws" + f.slice(4), e.ri = a, e.url = f;
        var g = b.WebSocket || b.MozWebSocket;
        e.ws = new g(e.url), e.ws.onmessage = function(a) {
            e.ri._didMessage(a.data)
        }, e.unload_ref = c.unload_add(function() {
            e.ws.close()
        }), e.ws.onclose = function() {
            e.ri._didMessage(c.closeFrame(1006, "WebSocket connection broken"))
        }
    };
    z.prototype.doSend = function(a) {
        this.ws.send("[" + a + "]")
    }, z.prototype.doCleanup = function() {
        var a = this, b = a.ws;
        b && (b.onmessage = b.onclose = null, b.close(), c.unload_del(a.unload_ref), a.unload_ref = a.ri = a.ws = null)
    }, z.enabled = function() {
        return !(!b.WebSocket && !b.MozWebSocket)
    }, z.roundTrips = 2;
    var A = function() {
    };
    A.prototype.send_constructor = function(a) {
        var b = this;
        b.send_buffer = [], b.sender = a
    }, A.prototype.doSend = function(a) {
        var b = this;
        b.send_buffer.push(a), b.send_stop || b.send_schedule()
    }, A.prototype.send_schedule_wait = function() {
        var a, b = this;
        b.send_stop = function() {
            b.send_stop = null, clearTimeout(a)
        }, a = c.delay(25, function() {
            b.send_stop = null, b.send_schedule()
        })
    }, A.prototype.send_schedule = function() {
        var a = this;
        if (a.send_buffer.length > 0) {
            var b = "[" + a.send_buffer.join(",") + "]";
            a.send_stop = a.sender(a.trans_url, b, function(b, c) {
                a.send_stop = null, b === !1 ? a.ri._didClose(1006, "Sending error " + c) : a.send_schedule_wait()
            }), a.send_buffer = []
        }
    }, A.prototype.send_destructor = function() {
        var a = this;
        a._send_stop && a._send_stop(), a._send_stop = null
    };
    var B = function(b, d, e) {
        var f = this;
        if (!("_send_form" in f)) {
            var g = f._send_form = a.createElement("form"), h = f._send_area = a.createElement("textarea");
            h.name = "d", g.style.display = "none", g.style.position = "absolute", g.method = "POST", g.enctype = "application/x-www-form-urlencoded", g.acceptCharset = "UTF-8", g.appendChild(h), a.body.appendChild(g)
        }
        var g = f._send_form, h = f._send_area, i = "a" + c.random_string(8);
        g.target = i, g.action = b + "/jsonp_send?i=" + i;
        var j;
        try {
            j = a.createElement('<iframe name="' + i + '">')
        } catch (k) {
            j = a.createElement("iframe"), j.name = i
        }
        j.id = i, g.appendChild(j), j.style.display = "none";
        try {
            h.value = d
        } catch (l) {
            c.log("Your browser is seriously broken. Go home! " + l.message)
        }
        g.submit();
        var m = function() {
            j.onerror && (j.onreadystatechange = j.onerror = j.onload = null, c.delay(500, function() {
                j.parentNode.removeChild(j), j = null
            }), h.value = "", e(!0))
        };
        return j.onerror = j.onload = m, j.onreadystatechange = function() {
            "complete" == j.readyState && m()
        }, m
    }, C = function(a) {
        return function(b, c, d) {
            var e = new a("POST", b + "/xhr_send", c);
            return e.onfinish = function(a) {
                d(200 === a || 204 === a, "http status " + a)
            }, function(a) {
                d(!1, a)
            }
        }
    }, D = function(b, d) {
        var e, f, g = a.createElement("script"), h = function(a) {
            f && (f.parentNode.removeChild(f), f = null), g && (clearTimeout(e), g.parentNode.removeChild(g), g.onreadystatechange = g.onerror = g.onload = g.onclick = null, g = null, d(a), d = null)
        }, i = !1, j = null;
        if (g.id = "a" + c.random_string(8), g.src = b, g.type = "text/javascript", g.charset = "UTF-8", g.onerror = function() {
            j || (j = setTimeout(function() {
                i || h(c.closeFrame(1006, "JSONP script loaded abnormally (onerror)"))
            }, 1e3))
        }, g.onload = function() {
            h(c.closeFrame(1006, "JSONP script loaded abnormally (onload)"))
        }, g.onreadystatechange = function() {
            if (/loaded|closed/.test(g.readyState)) {
                if (g && g.htmlFor && g.onclick) {
                    i = !0;
                    try {
                        g.onclick()
                    } catch (a) {
                    }
                }
                g && h(c.closeFrame(1006, "JSONP script loaded abnormally (onreadystatechange)"))
            }
        }, "undefined" == typeof g.async && a.attachEvent)
            if (/opera/i.test(navigator.userAgent))
                f = a.createElement("script"), f.text = "try{var a = document.getElementById('" + g.id + "'); if(a)a.onerror();}catch(x){};", g.async = f.async = !1;
            else {
                try {
                    g.htmlFor = g.id, g.event = "onclick"
                } catch (k) {
                }
                g.async = !0
            }
        "undefined" != typeof g.async && (g.async = !0), e = setTimeout(function() {
            h(c.closeFrame(1006, "JSONP script loaded abnormally (timeout)"))
        }, 35e3);
        var l = a.getElementsByTagName("head")[0];
        return l.insertBefore(g, l.firstChild), f && l.insertBefore(f, l.firstChild), h
    }, E = y["jsonp-polling"] = function(a, b) {
        c.polluteGlobalNamespace();
        var d = this;
        d.ri = a, d.trans_url = b, d.send_constructor(B), d._schedule_recv()
    };
    E.prototype = new A, E.prototype._schedule_recv = function() {
        var a = this, b = function(b) {
            a._recv_stop = null, b && (a._is_closing || a.ri._didMessage(b)), a._is_closing || a._schedule_recv()
        };
        a._recv_stop = F(a.trans_url + "/jsonp", D, b)
    }, E.enabled = function() {
        return !0
    }, E.need_body = !0, E.prototype.doCleanup = function() {
        var a = this;
        a._is_closing = !0, a._recv_stop && a._recv_stop(), a.ri = a._recv_stop = null, a.send_destructor()
    };
    var F = function(a, d, e) {
        var f = "a" + c.random_string(6), g = a + "?c=" + escape(h + "." + f), i = 0, j = function(a) {
            switch (i) {
                case 0:
                    delete b[h][f], e(a);
                    break;
                case 1:
                    e(a), i = 2;
                    break;
                case 2:
                    delete b[h][f]
            }
        }, k = d(g, j);
        b[h][f] = k;
        var l = function() {
            b[h][f] && (i = 1, b[h][f](c.closeFrame(1e3, "JSONP user aborted read")))
        };
        return l
    }, G = function() {
    };
    G.prototype = new A, G.prototype.run = function(a, b, c, d, e) {
        var f = this;
        f.ri = a, f.trans_url = b, f.send_constructor(C(e)), f.poll = new $(a, d, b + c, e)
    }, G.prototype.doCleanup = function() {
        var a = this;
        a.poll && (a.poll.abort(), a.poll = null)
    };
    var H = y["xhr-streaming"] = function(a, b) {
        this.run(a, b, "/xhr_streaming", db, c.XHRCorsObject)
    };
    H.prototype = new G, H.enabled = function() {
        return b.XMLHttpRequest && "withCredentials" in new XMLHttpRequest && !/opera/i.test(navigator.userAgent)
    }, H.roundTrips = 2, H.need_body = !0;
    var I = y["xdr-streaming"] = function(a, b) {
        this.run(a, b, "/xhr_streaming", db, c.XDRObject)
    };
    I.prototype = new G, I.enabled = function() {
        return !!b.XDomainRequest
    }, I.roundTrips = 2;
    var J = y["xhr-polling"] = function(a, b) {
        this.run(a, b, "/xhr", db, c.XHRCorsObject)
    };
    J.prototype = new G, J.enabled = H.enabled, J.roundTrips = 2;
    var K = y["xdr-polling"] = function(a, b) {
        this.run(a, b, "/xhr", db, c.XDRObject)
    };
    K.prototype = new G, K.enabled = I.enabled, K.roundTrips = 2;
    var L = function() {
    };
    L.prototype.i_constructor = function(a, b, d) {
        var e = this;
        e.ri = a, e.origin = c.getOrigin(d), e.base_url = d, e.trans_url = b;
        var f = d + "/iframe.html";
        e.ri._options.devel && (f += "?t=" + +new Date), e.window_id = c.random_string(8), f += "#" + e.window_id, e.iframeObj = c.createIframe(f, function(a) {
            e.ri._didClose(1006, "Unable to load an iframe (" + a + ")")
        }), e.onmessage_cb = c.bind(e.onmessage, e), c.attachMessage(e.onmessage_cb)
    }, L.prototype.doCleanup = function() {
        var a = this;
        if (a.iframeObj) {
            c.detachMessage(a.onmessage_cb);
            try {
                a.iframeObj.iframe.contentWindow && a.postMessage("c")
            } catch (b) {
            }
            a.iframeObj.cleanup(), a.iframeObj = null, a.onmessage_cb = a.iframeObj = null
        }
    }, L.prototype.onmessage = function(a) {
        var b = this;
        if (a.origin === b.origin) {
            var c = a.data.slice(0, 8), d = a.data.slice(8, 9), e = a.data.slice(9);
            if (c === b.window_id)
                switch (d) {
                    case "s":
                        b.iframeObj.loaded(), b.postMessage("s", JSON.stringify([y.version, b.protocol, b.trans_url, b.base_url]));
                        break;
                    case "t":
                        b.ri._didMessage(e)
                }
        }
    }, L.prototype.postMessage = function(a, b) {
        var c = this;
        c.iframeObj.post(c.window_id + a + (b || ""), c.origin)
    }, L.prototype.doSend = function(a) {
        this.postMessage("m", a)
    }, L.enabled = function() {
        var a = navigator && navigator.userAgent && -1 !== navigator.userAgent.indexOf("Konqueror");
        return ("function" == typeof b.postMessage || "object" == typeof b.postMessage) && !a
    };
    var M, N = function(a, d) {
        parent !== b ? parent.postMessage(M + a + (d || ""), "*") : c.log("Can't postMessage, no parent window.", a, d)
    }, O = function() {
    };
    O.prototype._didClose = function(a, b) {
        N("t", c.closeFrame(a, b))
    }, O.prototype._didMessage = function(a) {
        N("t", a)
    }, O.prototype._doSend = function(a) {
        this._transport.doSend(a)
    }, O.prototype._doCleanup = function() {
        this._transport.doCleanup()
    }, c.parent_origin = void 0, y.bootstrap_iframe = function() {
        var d;
        M = a.location.hash.slice(1);
        var e = function(a) {
            if (a.source === parent && ("undefined" == typeof c.parent_origin && (c.parent_origin = a.origin), a.origin === c.parent_origin)) {
                var e = a.data.slice(0, 8), f = a.data.slice(8, 9), g = a.data.slice(9);
                if (e === M)
                    switch (f) {
                        case "s":
                            var h = JSON.parse(g), i = h[0], j = h[1], k = h[2], l = h[3];
                            if (i !== y.version && c.log('Incompatibile SockJS! Main site uses: "' + i + '", the iframe:' + ' "' + y.version + '".'), !c.flatUrl(k) || !c.flatUrl(l))
                                return c.log("Only basic urls are supported in SockJS"), void 0;
                            if (!c.isSameOriginUrl(k) || !c.isSameOriginUrl(l))
                                return c.log("Can't connect to different domain from within an iframe. (" + JSON.stringify([b.location.href, k, l]) + ")"), void 0;
                            d = new O, d._transport = new O[j](d, k, l);
                            break;
                        case "m":
                            d._doSend(g);
                            break;
                        case "c":
                            d && d._doCleanup(), d = null
                    }
            }
        };
        c.attachMessage(e), N("s")
    };
    var P = function(a, b) {
        var d = this;
        c.delay(function() {
            d.doXhr(a, b)
        })
    };
    P.prototype = new f(["finish"]), P.prototype.doXhr = function(a, b) {
        var d = this, e = (new Date).getTime(), f = new b("GET", a + "/info?seq=" + c.random_string(8) ), g = c.delay(8e3, function() {
            f.ontimeout()
        });
        f.onfinish = function(a, b) {
            if (clearTimeout(g), g = null, 200 === a) {
                var c = (new Date).getTime() - e, f = JSON.parse(b);
                "object" != typeof f && (f = {}), d.emit("finish", f, c)
            } else
                d.emit("finish")
        }, f.ontimeout = function() {
            f.close(), d.emit("finish")
        }
    };
    var Q = function(b) {
        var d = this, e = function() {
            var a = new L;
            a.protocol = "w-iframe-info-receiver";
            var c = function(b) {
                if ("string" == typeof b && "m" === b.substr(0, 1)) {
                    var c = JSON.parse(b.substr(1)), e = c[0], f = c[1];
                    d.emit("finish", e, f)
                } else
                    d.emit("finish");
                a.doCleanup(), a = null
            }, e = {_options: {},_didClose: c,_didMessage: c};
            a.i_constructor(e, b, b)
        };
        a.body ? e() : c.attachEvent("load", e)
    };
    Q.prototype = new f(["finish"]);
    var R = function() {
        var a = this;
        c.delay(function() {
            a.emit("finish", {}, 2e3)
        })
    };
    R.prototype = new f(["finish"]);
    var S = function(a) {
        if (c.isSameOriginUrl(a))
            return new P(a, c.XHRLocalObject);
        switch (c.isXHRCorsCapable()) {
            case 1:
                return new P(a, c.XHRLocalObject);
            case 2:
                return c.isSameOriginScheme(a) ? new P(a, c.XDRObject) : new R;
            case 3:
                return new Q(a);
            default:
                return new R
        }
    }, T = O["w-iframe-info-receiver"] = function(a, b, d) {
        var e = new P(d, c.XHRLocalObject);
        e.onfinish = function(b, c) {
            a._didMessage("m" + JSON.stringify([b, c])), a._didClose()
        }
    };
    T.prototype.doCleanup = function() {
    };
    var U = y["iframe-eventsource"] = function() {
        var a = this;
        a.protocol = "w-iframe-eventsource", a.i_constructor.apply(a, arguments)
    };
    U.prototype = new L, U.enabled = function() {
        return "EventSource" in b && L.enabled()
    }, U.need_body = !0, U.roundTrips = 3;
    var V = O["w-iframe-eventsource"] = function(a, b) {
        this.run(a, b, "/eventsource", _, c.XHRLocalObject)
    };
    V.prototype = new G;
    var W = y["iframe-xhr-polling"] = function() {
        var a = this;
        a.protocol = "w-iframe-xhr-polling", a.i_constructor.apply(a, arguments)
    };
    W.prototype = new L, W.enabled = function() {
        return b.XMLHttpRequest && L.enabled()
    }, W.need_body = !0, W.roundTrips = 3;
    var X = O["w-iframe-xhr-polling"] = function(a, b) {
        this.run(a, b, "/xhr", db, c.XHRLocalObject)
    };
    X.prototype = new G;
    var Y = y["iframe-htmlfile"] = function() {
        var a = this;
        a.protocol = "w-iframe-htmlfile", a.i_constructor.apply(a, arguments)
    };
    Y.prototype = new L, Y.enabled = function() {
        return L.enabled()
    }, Y.need_body = !0, Y.roundTrips = 3;
    var Z = O["w-iframe-htmlfile"] = function(a, b) {
        this.run(a, b, "/htmlfile", cb, c.XHRLocalObject)
    };
    Z.prototype = new G;
    var $ = function(a, b, c, d) {
        var e = this;
        e.ri = a, e.Receiver = b, e.recv_url = c, e.AjaxObject = d, e._scheduleRecv()
    };
    $.prototype._scheduleRecv = function() {
        var a = this, b = a.poll = new a.Receiver(a.recv_url, a.AjaxObject), c = 0;
        b.onmessage = function(b) {
            c += 1, a.ri._didMessage(b.data)
        }, b.onclose = function(c) {
            a.poll = b = b.onmessage = b.onclose = null, a.poll_is_closing || ("permanent" === c.reason ? a.ri._didClose(1006, "Polling error (" + c.reason + ")") : a._scheduleRecv())
        }
    }, $.prototype.abort = function() {
        var a = this;
        a.poll_is_closing = !0, a.poll && a.poll.abort()
    };
    var _ = function(a) {
        var b = this, d = new EventSource(a);
        d.onmessage = function(a) {
            b.dispatchEvent(new e("message", {data: unescape(a.data)}))
        }, b.es_close = d.onerror = function(a, f) {
            var g = f ? "user" : 2 !== d.readyState ? "network" : "permanent";
            b.es_close = d.onmessage = d.onerror = null, d.close(), d = null, c.delay(200, function() {
                b.dispatchEvent(new e("close", {reason: g}))
            })
        }
    };
    _.prototype = new d, _.prototype.abort = function() {
        var a = this;
        a.es_close && a.es_close({}, !0)
    };
    var ab, bb = function() {
        if (void 0 === ab)
            if ("ActiveXObject" in b)
                try {
                    ab = !!new ActiveXObject("htmlfile")
                } catch (a) {
                }
            else
                ab = !1;
        return ab
    }, cb = function(a) {
        var d = this;
        c.polluteGlobalNamespace(), d.id = "a" + c.random_string(6, 26), a += (-1 === a.indexOf("?") ? "?" : "&") + "c=" + escape(h + "." + d.id);
        var f, g = bb() ? c.createHtmlfile : c.createIframe;
        b[h][d.id] = {start: function() {
                f.loaded()
            },message: function(a) {
                d.dispatchEvent(new e("message", {data: a}))
            },stop: function() {
                d.iframe_close({}, "network")
            }}, d.iframe_close = function(a, c) {
            f.cleanup(), d.iframe_close = f = null, delete b[h][d.id], d.dispatchEvent(new e("close", {reason: c}))
        }, f = g(a, function() {
            d.iframe_close({}, "permanent")
        })
    };
    cb.prototype = new d, cb.prototype.abort = function() {
        var a = this;
        a.iframe_close && a.iframe_close({}, "user")
    };
    var db = function(a, b) {
        var c = this, d = 0;
        c.xo = new b("POST", a, null), c.xo.onchunk = function(a, b) {
            if (200 === a)
                for (; ; ) {
                    var f = b.slice(d), g = f.indexOf("\n");
                    if (-1 === g)
                        break;
                    d += g + 1;
                    var h = f.slice(0, g);
                    c.dispatchEvent(new e("message", {data: h}))
                }
        }, c.xo.onfinish = function(a, b) {
            c.xo.onchunk(a, b), c.xo = null;
            var d = 200 === a ? "network" : "permanent";
            c.dispatchEvent(new e("close", {reason: d}))
        }
    };
    return db.prototype = new d, db.prototype.abort = function() {
        var a = this;
        a.xo && (a.xo.close(), a.dispatchEvent(new e("close", {reason: "user"})), a.xo = null)
    }, y.getUtils = function() {
        return c
    }, y.getIframeTransport = function() {
        return L
    }, y
}(), "_sockjs_onload" in window && setTimeout(_sockjs_onload, 1), "function" == typeof define && define.amd && define("sockjs", [], function() {
    return SockJS
}), Meteor._DdpClientStream = function(a) {
    var b = this;
    b._initCommon(), b.HEARTBEAT_TIMEOUT = 6e4, b.rawUrl = a, b.socket = null, b.sent_update_available = !1, b.heartbeatTimer = null, "undefined" != typeof window && window.addEventListener && window.addEventListener("online", _.bind(b._online, b), !1), b._launchConnection()
}, _.extend(Meteor._DdpClientStream.prototype, {send: function(a) {
        var b = this;
        b.currentStatus.connected && b.socket.send(a)
    },_connected: function(a) {
        var b = this;
        if (b.connectionTimer && (clearTimeout(b.connectionTimer), b.connectionTimer = null), !b.currentStatus.connected) {
            try {
                var c = JSON.parse(a)
            } catch (d) {
                Meteor._debug("DEBUG: malformed welcome packet", a)
            }
            c && c.server_id ? __meteor_runtime_config__.serverId && __meteor_runtime_config__.serverId !== c.server_id && !b.sent_update_available && (b.sent_update_available = !0, _.each(b.eventCallbacks.update_available, function(a) {
                a()
            })) : Meteor._debug("DEBUG: invalid welcome packet", c), b.currentStatus.status = "connected", b.currentStatus.connected = !0, b.currentStatus.retryCount = 0, b.statusChanged(), _.each(b.eventCallbacks.reset, function(a) {
                a()
            })
        }
    },_cleanup: function() {
        var a = this;
        a._clearConnectionAndHeartbeatTimers(), a.socket && (a.socket.onmessage = a.socket.onclose = a.socket.onerror = function() {
        }, a.socket.close(), a.socket = null)
    },_clearConnectionAndHeartbeatTimers: function() {
        var a = this;
        a.connectionTimer && (clearTimeout(a.connectionTimer), a.connectionTimer = null), a.heartbeatTimer && (clearTimeout(a.heartbeatTimer), a.heartbeatTimer = null)
    },_heartbeat_timeout: function() {
        var a = this;
        Meteor._debug("Connection timeout. No heartbeat received."), a._lostConnection()
    },_heartbeat_received: function() {
        var a = this;
        a._forcedToDisconnect || (a.heartbeatTimer && clearTimeout(a.heartbeatTimer), a.heartbeatTimer = setTimeout(_.bind(a._heartbeat_timeout, a), a.HEARTBEAT_TIMEOUT))
    },_sockjsProtocolsWhitelist: function() {
        var a = ["xdr-polling", "xhr-polling", "iframe-xhr-polling", "jsonp-polling"], b = navigator && /iPhone|iPad|iPod/.test(navigator.userAgent) && /OS 4_|OS 5_/.test(navigator.userAgent);
        return b || (a = ["websocket"].concat(a)), a
    },_launchConnection: function() {
        var a = this;
        a._cleanup(), a.socket = new SockJS(Meteor._DdpClientStream._toSockjsUrl(a.rawUrl), void 0, {debug: !1,protocols_whitelist: a._sockjsProtocolsWhitelist()}), a.socket.onmessage = function(b) {
            a._heartbeat_received(), "connecting" === a.currentStatus.status ? a._connected(b.data) : a.currentStatus.connected && _.each(a.eventCallbacks.message, function(a) {
                a(b.data)
            })
        }, a.socket.onclose = function() {
            a._lostConnection()
        }, a.socket.onerror = function() {
            Meteor._debug("stream error", _.toArray(arguments), (new Date).toDateString())
        }, a.socket.onheartbeat = function() {
            a._heartbeat_received()
        }, a.connectionTimer && clearTimeout(a.connectionTimer), a.connectionTimer = setTimeout(_.bind(a._lostConnection, a), a.CONNECT_TIMEOUT)
    }});
var startsWith = function(a, b) {
    return a.length >= b.length && a.substring(0, b.length) === b
}, endsWith = function(a, b) {
    return a.length >= b.length && a.substring(a.length - b.length) === b
}, translateUrl = function(a, b, c) {
    b || (b = "http");
    var d, e = a.match(/^ddp(i?)\+sockjs:\/\//), f = a.match(/^http(s?):\/\//);
    if (e) {
        var g = a.substr(e[0].length);
        d = "i" === e[1] ? b : b + "s";
        var h = g.indexOf("/"), i = -1 === h ? g : g.substr(0, h), j = -1 === h ? "" : g.substr(h);
        return i = i.replace(/\*/g, function() {
            return Math.floor(10 * Random.fraction())
        }), d + "://" + i + j
    }
    if (f) {
        d = f[1] ? b + "s" : b;
        var k = a.substr(f[0].length);
        a = d + "://" + k
    }
    return -1 !== a.indexOf("://") || startsWith(a, "/") || (a = b + "://" + a), endsWith(a, "/") ? a + c : a + "/" + c
};
_.extend(Meteor._DdpClientStream.prototype, {on: function(a, b) {
        var c = this;
        if ("message" !== a && "reset" !== a && "update_available" !== a)
            throw new Error("unknown event type: " + a);
        c.eventCallbacks[a] || (c.eventCallbacks[a] = []), c.eventCallbacks[a].push(b)
    },_initCommon: function() {
        var a = this;
        a.CONNECT_TIMEOUT = 1e4, a.RETRY_BASE_TIMEOUT = 1e3, a.RETRY_EXPONENT = 2.2, a.RETRY_MAX_TIMEOUT = 3e5, a.RETRY_MIN_TIMEOUT = 10, a.RETRY_MIN_COUNT = 2, a.RETRY_FUZZ = .5, a.eventCallbacks = {}, a._forcedToDisconnect = !1, a.currentStatus = {status: "connecting",connected: !1,retryCount: 0}, a.statusListeners = "undefined" != typeof Deps && new Deps.Dependency, a.statusChanged = function() {
            a.statusListeners && a.statusListeners.changed()
        }, a.retryTimer = null, a.connectionTimer = null
    },reconnect: function(a) {
        var b = this;
        return b.currentStatus.connected ? (a && a._force && b._lostConnection(), void 0) : ("connecting" === b.currentStatus.status && b._lostConnection(), b.retryTimer && clearTimeout(b.retryTimer), b.retryTimer = null, b.currentStatus.retryCount -= 1, b._retryNow(), void 0)
    },forceDisconnect: function(a) {
        var b = this;
        b._forcedToDisconnect = !0, b._cleanup(), b.retryTimer && (clearTimeout(b.retryTimer), b.retryTimer = null), b.currentStatus = {status: "failed",connected: !1,retryCount: 0}, a && (b.currentStatus.reason = a), b.statusChanged()
    },_lostConnection: function() {
        var a = this;
        a._cleanup(), a._retryLater()
    },_retryTimeout: function(a) {
        var b = this;
        if (a < b.RETRY_MIN_COUNT)
            return b.RETRY_MIN_TIMEOUT;
        var c = Math.min(b.RETRY_MAX_TIMEOUT, b.RETRY_BASE_TIMEOUT * Math.pow(b.RETRY_EXPONENT, a));
        return c *= Random.fraction() * b.RETRY_FUZZ + (1 - b.RETRY_FUZZ / 2)
    },_online: function() {
        this.reconnect()
    },_retryLater: function() {
        var a = this, b = a._retryTimeout(a.currentStatus.retryCount);
        a.retryTimer && clearTimeout(a.retryTimer), a.retryTimer = setTimeout(_.bind(a._retryNow, a), b), a.currentStatus.status = "waiting", a.currentStatus.connected = !1, a.currentStatus.retryTime = (new Date).getTime() + b, a.statusChanged()
    },_retryNow: function() {
        var a = this;
        a._forcedToDisconnect || (a.currentStatus.retryCount += 1, a.currentStatus.status = "connecting", a.currentStatus.connected = !1, delete a.currentStatus.retryTime, a.statusChanged(), a._launchConnection())
    },status: function() {
        var a = this;
        return a.statusListeners && a.statusListeners.depend(), a.currentStatus
    }}), _.extend(Meteor._DdpClientStream, {_toSockjsUrl: function(a) {
        return translateUrl(a, "http", "sockjs")
    },_toWebsocketUrl: function(a) {
        var b = translateUrl(a, "ws", "websocket");
        return b
    }}), LocalCollection = function() {
    this.docs = {}, this._observeQueue = new Meteor._SynchronousQueue, this.next_qid = 1, this.queries = {}, this._savedOriginals = null, this.paused = !1
}, LocalCollection._applyChanges = function(a, b) {
    _.each(b, function(b, c) {
        void 0 === b ? delete a[c] : a[c] = b
    })
}, LocalCollection.MinimongoError = function(a) {
    var b = this;
    b.name = "MinimongoError", b.details = a
}, LocalCollection.MinimongoError.prototype = new Error, LocalCollection.prototype.find = function(a, b) {
    return 0 === arguments.length && (a = {}), new LocalCollection.Cursor(this, a, b)
}, LocalCollection.Cursor = function(a, b, c) {
    var d = this;
    c || (c = {}), this.collection = a, LocalCollection._selectorIsId(b) ? (d.selector_id = LocalCollection._idStringify(b), d.selector_f = LocalCollection._compileSelector(b), d.sort_f = void 0) : (d.selector_id = void 0, d.selector_f = LocalCollection._compileSelector(b), d.sort_f = c.sort ? LocalCollection._compileSort(c.sort) : null), d.skip = c.skip, d.limit = c.limit, d._transform = c.transform && "undefined" != typeof Deps ? Deps._makeNonreactive(c.transform) : c.transform, d.db_objects = null, d.cursor_pos = 0, "undefined" != typeof Deps && (d.reactive = void 0 === c.reactive ? !0 : c.reactive)
}, LocalCollection.Cursor.prototype.rewind = function() {
    var a = this;
    a.db_objects = null, a.cursor_pos = 0
}, LocalCollection.prototype.findOne = function(a, b) {
    return 0 === arguments.length && (a = {}), b = b || {}, b.limit = 1, this.find(a, b).fetch()[0]
}, LocalCollection.Cursor.prototype.forEach = function(a) {
    var b = this;
    for (null === b.db_objects && (b.db_objects = b._getRawObjects(!0)), b.reactive && b._depend({addedBefore: !0,removed: !0,changed: !0,movedBefore: !0}); b.cursor_pos < b.db_objects.length; ) {
        var c = EJSON.clone(b.db_objects[b.cursor_pos++]);
        b._transform && (c = b._transform(c)), a(c)
    }
}, LocalCollection.Cursor.prototype.getTransform = function() {
    var a = this;
    return a._transform
}, LocalCollection.Cursor.prototype.map = function(a) {
    var b = this, c = [];
    return b.forEach(function(b) {
        c.push(a(b))
    }), c
}, LocalCollection.Cursor.prototype.fetch = function() {
    var a = this, b = [];
    return a.forEach(function(a) {
        b.push(a)
    }), b
}, LocalCollection.Cursor.prototype.count = function() {
    var a = this;
    return a.reactive && a._depend({added: !0,removed: !0}), null === a.db_objects && (a.db_objects = a._getRawObjects(!0)), a.db_objects.length
}, LocalCollection._isOrderedChanges = function(a) {
    if (a.added && a.addedBefore)
        throw new Error("Please specify only one of added() and addedBefore()");
    return "function" == typeof a.addedBefore || "function" == typeof a.movedBefore
}, LocalCollection.LiveResultsSet = function() {
}, _.extend(LocalCollection.Cursor.prototype, {observe: function(a) {
        var b = this;
        return LocalCollection._observeFromObserveChanges(b, a)
    },observeChanges: function(a) {
        var b = this, c = LocalCollection._isOrderedChanges(a);
        if (!c && (b.skip || b.limit))
            throw new Error("must use ordered observe with skip or limit");
        var d, e = {selector_f: b.selector_f,sort_f: c && b.sort_f,results_snapshot: null,ordered: c,cursor: this,observeChanges: a.observeChanges};
        b.reactive && (d = b.collection.next_qid++, b.collection.queries[d] = e), e.results = b._getRawObjects(c), b.collection.paused && (e.results_snapshot = c ? [] : {});
        var f = function(a) {
            return a ? function() {
                var c = this, d = arguments;
                b.collection.paused || b.collection._observeQueue.queueTask(function() {
                    a.apply(c, d)
                })
            } : function() {
            }
        };
        e.added = f(a.added), e.changed = f(a.changed), e.removed = f(a.removed), c && (e.moved = f(a.moved), e.addedBefore = f(a.addedBefore), e.movedBefore = f(a.movedBefore)), a._suppress_initial || b.collection.paused || _.each(e.results, function(a) {
            var b = EJSON.clone(a);
            delete b._id, c && e.addedBefore(a._id, b, null), e.added(a._id, b)
        });
        var g = new LocalCollection.LiveResultsSet;
        return _.extend(g, {collection: b.collection,stop: function() {
                b.reactive && delete b.collection.queries[d]
            }}), b.reactive && Deps.active && Deps.onInvalidate(function() {
            g.stop()
        }), b.collection._observeQueue.drain(), g
    }}), LocalCollection.Cursor.prototype._getRawObjects = function(a) {
    var b = this, c = a ? [] : {};
    if (b.selector_id) {
        if (b.skip)
            return c;
        if (_.has(b.collection.docs, b.selector_id)) {
            var d = b.collection.docs[b.selector_id];
            a ? c.push(d) : c[b.selector_id] = d
        }
        return c
    }
    for (var e in b.collection.docs) {
        var f = b.collection.docs[e];
        if (b.selector_f(f) && (a ? c.push(f) : c[e] = f), b.limit && !b.skip && !b.sort_f && c.length === b.limit)
            return c
    }
    if (!a)
        return c;
    b.sort_f && c.sort(b.sort_f);
    var g = b.skip || 0, h = b.limit ? b.limit + g : c.length;
    return c.slice(g, h)
}, LocalCollection.Cursor.prototype._depend = function(a) {
    var b = this;
    if (Deps.active) {
        var c = new Deps.Dependency;
        c.depend();
        var d = _.bind(c.changed, c), e = {_suppress_initial: !0};
        _.each(["added", "changed", "removed", "addedBefore", "movedBefore"], function(b) {
            a[b] && (e[b] = d)
        }), b.observeChanges(e)
    }
}, LocalCollection.prototype.insert = function(a) {
    var b = this;
    a = EJSON.clone(a), _.has(a, "_id") || (a._id = LocalCollection._useOID ? new LocalCollection._ObjectID : Random.id());
    var c = LocalCollection._idStringify(a._id);
    if (_.has(b.docs, a._id))
        throw new LocalCollection.MinimongoError("Duplicate _id '" + a._id + "'");
    b._saveOriginal(c, void 0), b.docs[c] = a;
    var d = [];
    for (var e in b.queries) {
        var f = b.queries[e];
        f.selector_f(a) && (f.cursor.skip || f.cursor.limit ? d.push(e) : LocalCollection._insertInResults(f, a))
    }
    return _.each(d, function(a) {
        b.queries[a] && LocalCollection._recomputeResults(b.queries[a])
    }), b._observeQueue.drain(), a._id
}, LocalCollection.prototype.remove = function(a) {
    var b = this, c = [], d = [], e = LocalCollection._compileSelector(a), f = LocalCollection._idsMatchedBySelector(a);
    if (f)
        _.each(f, function(a) {
            var d = LocalCollection._idStringify(a);
            _.has(b.docs, d) && e(b.docs[d]) && c.push(d)
        });
    else
        for (var g in b.docs) {
            var h = b.docs[g];
            e(h) && c.push(g)
        }
    for (var i = [], j = 0; j < c.length; j++) {
        var k = c[j], l = b.docs[k];
        _.each(b.queries, function(a, b) {
            a.selector_f(l) && (a.cursor.skip || a.cursor.limit ? d.push(b) : i.push({qid: b,doc: l}))
        }), b._saveOriginal(k, l), delete b.docs[k]
    }
    _.each(i, function(a) {
        var c = b.queries[a.qid];
        c && LocalCollection._removeFromResults(c, a.doc)
    }), _.each(d, function(a) {
        var c = b.queries[a];
        c && LocalCollection._recomputeResults(c)
    }), b._observeQueue.drain()
}, LocalCollection.prototype.update = function(a, b, c) {
    var d = this;
    if (c || (c = {}), c.upsert)
        throw new Error("upsert not yet implemented");
    var e = LocalCollection._compileSelector(a), f = {};
    _.each(d.queries, function(a, b) {
        !a.cursor.skip && !a.cursor.limit || a.paused || (f[b] = EJSON.clone(a.results))
    });
    var g = {};
    for (var h in d.docs) {
        var i = d.docs[h];
        if (e(i) && (d._saveOriginal(h, i), d._modifyAndNotify(i, b, g), !c.multi))
            break
    }
    _.each(g, function(a, b) {
        var c = d.queries[b];
        c && LocalCollection._recomputeResults(c, f[b])
    }), d._observeQueue.drain()
}, LocalCollection.prototype._modifyAndNotify = function(a, b, c) {
    var d = this, e = {};
    for (var f in d.queries) {
        var g = d.queries[f];
        e[f] = g.ordered ? g.selector_f(a) : _.has(g.results, LocalCollection._idStringify(a._id))
    }
    var h = EJSON.clone(a);
    LocalCollection._modify(a, b);
    for (f in d.queries) {
        g = d.queries[f];
        var i = e[f], j = g.selector_f(a);
        g.cursor.skip || g.cursor.limit ? (i || j) && (c[f] = !0) : i && !j ? LocalCollection._removeFromResults(g, a) : !i && j ? LocalCollection._insertInResults(g, a) : i && j && LocalCollection._updateInResults(g, a, h)
    }
}, LocalCollection._insertInResults = function(a, b) {
    var c = EJSON.clone(b);
    if (delete c._id, a.ordered) {
        if (a.sort_f) {
            var d = LocalCollection._insertInSortedList(a.sort_f, a.results, b), e = a.results[d + 1];
            e = e ? e._id : null, a.addedBefore(b._id, c, e)
        } else
            a.addedBefore(b._id, c, null), a.results.push(b);
        a.added(b._id, c)
    } else
        a.added(b._id, c), a.results[LocalCollection._idStringify(b._id)] = b
}, LocalCollection._removeFromResults = function(a, b) {
    if (a.ordered) {
        var c = LocalCollection._findInOrderedResults(a, b);
        a.removed(b._id), a.results.splice(c, 1)
    } else {
        var d = LocalCollection._idStringify(b._id);
        a.removed(b._id), delete a.results[d]
    }
}, LocalCollection._updateInResults = function(a, b, c) {
    if (!EJSON.equals(b._id, c._id))
        throw new Error("Can't change a doc's _id while updating");
    var d = LocalCollection._makeChangedFields(b, c);
    if (!a.ordered)
        return _.isEmpty(d) || (a.changed(b._id, d), a.results[LocalCollection._idStringify(b._id)] = b), void 0;
    var e = LocalCollection._findInOrderedResults(a, b);
    if (_.isEmpty(d) || a.changed(b._id, d), a.sort_f) {
        a.results.splice(e, 1);
        var f = LocalCollection._insertInSortedList(a.sort_f, a.results, b);
        if (e !== f) {
            var g = a.results[f + 1];
            g = g ? g._id : null, a.movedBefore && a.movedBefore(b._id, g)
        }
    }
}, LocalCollection._recomputeResults = function(a, b) {
    b || (b = a.results), a.results = a.cursor._getRawObjects(a.ordered), a.paused || LocalCollection._diffQueryChanges(a.ordered, b, a.results, a)
}, LocalCollection._findInOrderedResults = function(a, b) {
    if (!a.ordered)
        throw new Error("Can't call _findInOrderedResults on unordered query");
    for (var c = 0; c < a.results.length; c++)
        if (a.results[c] === b)
            return c;
    throw Error("object missing from query")
}, LocalCollection._binarySearch = function(a, b, c) {
    for (var d = 0, e = b.length; e > 0; ) {
        var f = Math.floor(e / 2);
        a(c, b[d + f]) >= 0 ? (d += f + 1, e -= f + 1) : e = f
    }
    return d
}, LocalCollection._insertInSortedList = function(a, b, c) {
    if (0 === b.length)
        return b.push(c), 0;
    var d = LocalCollection._binarySearch(a, b, c);
    return b.splice(d, 0, c), d
}, LocalCollection.prototype.saveOriginals = function() {
    var a = this;
    if (a._savedOriginals)
        throw new Error("Called saveOriginals twice without retrieveOriginals");
    a._savedOriginals = {}
}, LocalCollection.prototype.retrieveOriginals = function() {
    var a = this;
    if (!a._savedOriginals)
        throw new Error("Called retrieveOriginals without saveOriginals");
    var b = a._savedOriginals;
    return a._savedOriginals = null, b
}, LocalCollection.prototype._saveOriginal = function(a, b) {
    var c = this;
    c._savedOriginals && (_.has(c._savedOriginals, a) || (c._savedOriginals[a] = EJSON.clone(b)))
}, LocalCollection.prototype.pauseObservers = function() {
    if (!this.paused) {
        this.paused = !0;
        for (var a in this.queries) {
            var b = this.queries[a];
            b.results_snapshot = EJSON.clone(b.results)
        }
    }
}, LocalCollection.prototype.resumeObservers = function() {
    var a = this;
    if (this.paused) {
        this.paused = !1;
        for (var b in this.queries) {
            var c = a.queries[b];
            LocalCollection._diffQueryChanges(c.ordered, c.results_snapshot, c.results, c), c.results_snapshot = null
        }
        a._observeQueue.drain()
    }
}, LocalCollection._idStringify = function(a) {
    if (a instanceof LocalCollection._ObjectID)
        return a.valueOf();
    if ("string" == typeof a)
        return "" === a ? a : "-" === a.substr(0, 1) || "~" === a.substr(0, 1) || LocalCollection._looksLikeObjectID(a) || "{" === a.substr(0, 1) ? "-" + a : a;
    if (void 0 === a)
        return "-";
    if ("object" == typeof a)
        throw new Error("Meteor does not currently support objects other than ObjectID as ids");
    return "~" + JSON.stringify(a)
}, LocalCollection._idParse = function(a) {
    return "" === a ? a : "-" === a ? void 0 : "-" === a.substr(0, 1) ? a.substr(1) : "~" === a.substr(0, 1) ? JSON.parse(a.substr(1)) : LocalCollection._looksLikeObjectID(a) ? new LocalCollection._ObjectID(a) : a
}, "undefined" != typeof Meteor && (Meteor.idParse = LocalCollection._idParse, Meteor.idStringify = LocalCollection._idStringify), LocalCollection._makeChangedFields = function(a, b) {
    var c = {};
    return LocalCollection._diffObjects(b, a, {leftOnly: function(a) {
            c[a] = void 0
        },rightOnly: function(a, b) {
            c[a] = b
        },both: function(a, b, d) {
            EJSON.equals(b, d) || (c[a] = d)
        }}), c
}, LocalCollection._observeFromObserveChanges = function(a, b) {
    var c = a.getTransform();
    if (c || (c = function(a) {
        return a
    }), b.addedAt && b.added)
        throw new Error("Please specify only one of added() and addedAt()");
    if (b.changedAt && b.changed)
        throw new Error("Please specify only one of changed() and changedAt()");
    if (b.removed && b.removedAt)
        throw new Error("Please specify only one of removed() and removedAt()");
    return b.addedAt || b.movedTo || b.changedAt || b.removedAt ? LocalCollection._observeOrderedFromObserveChanges(a, b, c) : LocalCollection._observeUnorderedFromObserveChanges(a, b, c)
}, LocalCollection._observeUnorderedFromObserveChanges = function(a, b, c) {
    var d = {}, e = !!b._suppress_initial, f = a.observeChanges({added: function(a, f) {
            var g = LocalCollection._idStringify(a), h = EJSON.clone(f);
            h._id = a, d[g] = h, e || b.added && b.added(c(h))
        },changed: function(a, f) {
            var g = LocalCollection._idStringify(a), h = d[g], i = EJSON.clone(h);
            LocalCollection._applyChanges(h, f), e || b.changed && b.changed(c(h), c(i))
        },removed: function(a) {
            var f = LocalCollection._idStringify(a), g = d[f];
            delete d[f], e || b.removed && b.removed(c(g))
        }});
    return e = !1, f
}, LocalCollection._observeOrderedFromObserveChanges = function(a, b, c) {
    var d = new OrderedDict(LocalCollection._idStringify), e = !!b._suppress_initial, f = a.observeChanges({addedBefore: function(a, f, g) {
            var h = EJSON.clone(f);
            if (h._id = a, d.putBefore(a, h, g ? g : null), !e)
                if (b.addedAt) {
                    var i = d.indexOf(a);
                    b.addedAt(c(EJSON.clone(h)), i, g)
                } else
                    b.added && b.added(c(EJSON.clone(h)))
        },changed: function(a, e) {
            var f = d.get(a);
            if (!f)
                throw new Error("Unknown id for changed: " + a);
            var g = EJSON.clone(f);
            if (LocalCollection._applyChanges(f, e), b.changedAt) {
                var h = d.indexOf(a);
                b.changedAt(c(EJSON.clone(f)), c(g), h)
            } else
                b.changed && b.changed(c(EJSON.clone(f)), c(g))
        },movedBefore: function(a, e) {
            var f, g = d.get(a);
            if (b.movedTo && (f = d.indexOf(a)), d.moveBefore(a, e ? e : null), b.movedTo) {
                var h = d.indexOf(a);
                b.movedTo(c(EJSON.clone(g)), f, h)
            } else
                b.moved && b.moved(c(EJSON.clone(g)))
        },removed: function(a) {
            var e, f = d.get(a);
            b.removedAt && (e = d.indexOf(a)), d.remove(a), b.removedAt && b.removedAt(c(f), e), b.removed && b.removed(c(f))
        }});
    return e = !1, f
};
var isArray = function(a) {
    return _.isArray(a) && !EJSON.isBinary(a)
}, _anyIfArray = function(a, b) {
    return isArray(a) ? _.any(a, b) : b(a)
}, _anyIfArrayPlus = function(a, b) {
    return b(a) ? !0 : isArray(a) && _.any(a, b)
}, hasOperators = function(a) {
    var b = void 0;
    for (var c in a) {
        var d = "$" === c.substr(0, 1);
        if (void 0 === b)
            b = d;
        else if (b !== d)
            throw new Error("Inconsistent selector: " + a)
    }
    return !!b
}, compileValueSelector = function(a) {
    if (null == a)
        return function(a) {
            return _anyIfArray(a, function(a) {
                return null == a
            })
        };
    if (!_.isObject(a))
        return function(b) {
            return _anyIfArray(b, function(b) {
                return b === a
            })
        };
    if (a instanceof RegExp)
        return function(b) {
            return void 0 === b ? !1 : _anyIfArray(b, function(b) {
                return a.test(b)
            })
        };
    if (isArray(a))
        return function(b) {
            return isArray(b) ? _anyIfArrayPlus(b, function(b) {
                return LocalCollection._f._equal(a, b)
            }) : !1
        };
    if (hasOperators(a)) {
        var b = [];
        return _.each(a, function(c, d) {
            if (!_.has(VALUE_OPERATORS, d))
                throw new Error("Unrecognized operator: " + d);
            b.push(VALUE_OPERATORS[d](c, a.$options))
        }), function(a) {
            return _.all(b, function(b) {
                return b(a)
            })
        }
    }
    return function(b) {
        return _anyIfArray(b, function(b) {
            return LocalCollection._f._equal(a, b)
        })
    }
}, LOGICAL_OPERATORS = {$and: function(a) {
        if (!isArray(a) || _.isEmpty(a))
            throw Error("$and/$or/$nor must be nonempty array");
        var b = _.map(a, compileDocumentSelector);
        return function(a) {
            return _.all(b, function(b) {
                return b(a)
            })
        }
    },$or: function(a) {
        if (!isArray(a) || _.isEmpty(a))
            throw Error("$and/$or/$nor must be nonempty array");
        var b = _.map(a, compileDocumentSelector);
        return function(a) {
            return _.any(b, function(b) {
                return b(a)
            })
        }
    },$nor: function(a) {
        if (!isArray(a) || _.isEmpty(a))
            throw Error("$and/$or/$nor must be nonempty array");
        var b = _.map(a, compileDocumentSelector);
        return function(a) {
            return _.all(b, function(b) {
                return !b(a)
            })
        }
    },$where: function(a) {
        return a instanceof Function || (a = Function("return " + a)), function(b) {
            return a.call(b)
        }
    }}, VALUE_OPERATORS = {$in: function(a) {
        if (!isArray(a))
            throw new Error("Argument to $in must be array");
        return function(b) {
            return _anyIfArrayPlus(b, function(b) {
                return _.any(a, function(a) {
                    return LocalCollection._f._equal(a, b)
                })
            })
        }
    },$all: function(a) {
        if (!isArray(a))
            throw new Error("Argument to $all must be array");
        return function(b) {
            return isArray(b) ? _.all(a, function(a) {
                return _.any(b, function(b) {
                    return LocalCollection._f._equal(a, b)
                })
            }) : !1
        }
    },$lt: function(a) {
        return function(b) {
            return _anyIfArray(b, function(b) {
                return LocalCollection._f._cmp(b, a) < 0
            })
        }
    },$lte: function(a) {
        return function(b) {
            return _anyIfArray(b, function(b) {
                return LocalCollection._f._cmp(b, a) <= 0
            })
        }
    },$gt: function(a) {
        return function(b) {
            return _anyIfArray(b, function(b) {
                return LocalCollection._f._cmp(b, a) > 0
            })
        }
    },$gte: function(a) {
        return function(b) {
            return _anyIfArray(b, function(b) {
                return LocalCollection._f._cmp(b, a) >= 0
            })
        }
    },$ne: function(a) {
        return function(b) {
            return !_anyIfArrayPlus(b, function(b) {
                return LocalCollection._f._equal(b, a)
            })
        }
    },$nin: function(a) {
        if (!isArray(a))
            throw new Error("Argument to $nin must be array");
        var b = VALUE_OPERATORS.$in(a);
        return function(a) {
            return void 0 === a ? !0 : !b(a)
        }
    },$exists: function(a) {
        return function(b) {
            return a === (void 0 !== b)
        }
    },$mod: function(a) {
        var b = a[0], c = a[1];
        return function(a) {
            return _anyIfArray(a, function(a) {
                return a % b === c
            })
        }
    },$size: function(a) {
        return function(b) {
            return isArray(b) && a === b.length
        }
    },$type: function(a) {
        return function(b) {
            return void 0 === b ? !1 : _anyIfArray(b, function(b) {
                return LocalCollection._f._type(b) === a
            })
        }
    },$regex: function(a, b) {
        if (void 0 !== b) {
            if (/[^gim]/.test(b))
                throw new Error("Only the i, m, and g regexp options are supported");
            var c = a instanceof RegExp ? a.source : a;
            a = new RegExp(c, b)
        } else
            a instanceof RegExp || (a = new RegExp(a));
        return function(b) {
            return void 0 === b ? !1 : _anyIfArray(b, function(b) {
                return a.test(b)
            })
        }
    },$options: function() {
        return function() {
            return !0
        }
    },$elemMatch: function(a) {
        var b = compileDocumentSelector(a);
        return function(a) {
            return isArray(a) ? _.any(a, function(a) {
                return b(a)
            }) : !1
        }
    },$not: function(a) {
        var b = compileValueSelector(a);
        return function(a) {
            return !b(a)
        }
    }};
LocalCollection._f = {_type: function(a) {
        return "number" == typeof a ? 1 : "string" == typeof a ? 2 : "boolean" == typeof a ? 8 : isArray(a) ? 4 : null === a ? 10 : a instanceof RegExp ? 11 : "function" == typeof a ? 13 : a instanceof Date ? 9 : EJSON.isBinary(a) ? 5 : a instanceof Meteor.Collection.ObjectID ? 7 : 3
    },_equal: function(a, b) {
        return EJSON.equals(a, b, {keyOrderSensitive: !0})
    },_typeorder: function(a) {
        return [-1, 1, 2, 3, 4, 5, -1, 6, 7, 8, 0, 9, -1, 100, 2, 100, 1, 8, 1][a]
    },_cmp: function(a, b) {
        if (void 0 === a)
            return void 0 === b ? 0 : -1;
        if (void 0 === b)
            return 1;
        var c = LocalCollection._f._type(a), d = LocalCollection._f._type(b), e = LocalCollection._f._typeorder(c), f = LocalCollection._f._typeorder(d);
        if (e !== f)
            return f > e ? -1 : 1;
        if (c !== d)
            throw Error("Missing type coercion logic in _cmp");
        if (7 === c && (c = d = 2, a = a.toHexString(), b = b.toHexString()), 9 === c && (c = d = 1, a = a.getTime(), b = b.getTime()), 1 === c)
            return a - b;
        if (2 === d)
            return b > a ? -1 : a === b ? 0 : 1;
        if (3 === c) {
            var g = function(a) {
                var b = [];
                for (var c in a)
                    b.push(c), b.push(a[c]);
                return b
            };
            return LocalCollection._f._cmp(g(a), g(b))
        }
        if (4 === c)
            for (var h = 0; ; h++) {
                if (h === a.length)
                    return h === b.length ? 0 : -1;
                if (h === b.length)
                    return 1;
                var i = LocalCollection._f._cmp(a[h], b[h]);
                if (0 !== i)
                    return i
            }
        if (5 === c) {
            if (a.length !== b.length)
                return a.length - b.length;
            for (h = 0; h < a.length; h++) {
                if (a[h] < b[h])
                    return -1;
                if (a[h] > b[h])
                    return 1
            }
            return 0
        }
        if (8 === c)
            return a ? b ? 0 : 1 : b ? -1 : 0;
        if (10 === c)
            return 0;
        if (11 === c)
            throw Error("Sorting not supported on regular expression");
        if (13 === c)
            throw Error("Sorting not supported on Javascript code");
        throw Error("Unknown type to sort")
    }}, LocalCollection._matches = function(a, b) {
    return LocalCollection._compileSelector(a)(b)
}, LocalCollection._makeLookupFunction = function(a) {
    var b, c, d, e = a.indexOf(".");
    if (-1 === e)
        b = a;
    else {
        b = a.substr(0, e);
        var f = a.substr(e + 1);
        c = LocalCollection._makeLookupFunction(f), d = /^\d+(\.|$)/.test(f)
    }
    return function(a) {
        if (null == a)
            return [void 0];
        var e = a[b];
        return c ? isArray(e) && 0 === e.length ? [void 0] : ((!isArray(e) || d) && (e = [e]), Array.prototype.concat.apply([], _.map(e, c))) : [e]
    }
};
var compileDocumentSelector = function(a) {
    var b = [];
    return _.each(a, function(a, c) {
        if ("$" === c.substr(0, 1)) {
            if (!_.has(LOGICAL_OPERATORS, c))
                throw new Error("Unrecognized logical operator: " + c);
            b.push(LOGICAL_OPERATORS[c](a))
        } else {
            var d = LocalCollection._makeLookupFunction(c), e = compileValueSelector(a);
            b.push(function(a) {
                var b = d(a);
                return _.any(b, e)
            })
        }
    }), function(a) {
        return _.all(b, function(b) {
            return b(a)
        })
    }
};
if (LocalCollection._compileSelector = function(a) {
    if (a instanceof Function)
        return function(b) {
            return a.call(b)
        };
    if (LocalCollection._selectorIsId(a))
        return function(b) {
            return EJSON.equals(b._id, a)
        };
    if (!a || "_id" in a && !a._id)
        return function() {
            return !1
        };
    if ("boolean" == typeof a || isArray(a) || EJSON.isBinary(a))
        throw new Error("Invalid selector: " + a);
    return compileDocumentSelector(a)
}, LocalCollection._compileSort = function(a) {
    var b = [];
    if (a instanceof Array)
        for (var c = 0; c < a.length; c++)
            "string" == typeof a[c] ? b.push({lookup: LocalCollection._makeLookupFunction(a[c]),ascending: !0}) : b.push({lookup: LocalCollection._makeLookupFunction(a[c][0]),ascending: "desc" !== a[c][1]});
    else {
        if ("object" != typeof a)
            throw Error("Bad sort specification: ", JSON.stringify(a));
        for (var d in a)
            b.push({lookup: LocalCollection._makeLookupFunction(d),ascending: a[d] >= 0})
    }
    if (0 === b.length)
        return function() {
            return 0
        };
    var e = function(a, b) {
        var c, d = !0;
        return _.each(a, function(a) {
            isArray(a) || (a = [a]), isArray(a) && 0 === a.length && (a = [void 0]), _.each(a, function(a) {
                if (d)
                    c = a, d = !1;
                else {
                    var e = LocalCollection._f._cmp(c, a);
                    (b && e > 0 || !b && 0 > e) && (c = a)
                }
            })
        }), c
    };
    return function(a, c) {
        for (var d = 0; d < b.length; ++d) {
            var f = b[d], g = e(f.lookup(a), f.ascending), h = e(f.lookup(c), f.ascending), i = LocalCollection._f._cmp(g, h);
            if (0 !== i)
                return f.ascending ? i : -i
        }
        return 0
    }
}, LocalCollection._modify = function(a, b) {
    var c = !1;
    for (var d in b) {
        c = "$" === d.substr(0, 1);
        break
    }
    var e;
    if (c) {
        var e = EJSON.clone(a);
        for (var f in b) {
            var g = LocalCollection._modifiers[f];
            if (!g)
                throw Error("Invalid modifier specified " + f);
            for (var h in b[f]) {
                if (h.length && "." === h[h.length - 1])
                    throw Error("Invalid mod field name, may not end in a period");
                var i = b[f][h], j = h.split("."), k = !!LocalCollection._noCreateModifiers[f], l = "$rename" === f, m = LocalCollection._findModTarget(e, j, k, l), n = j.pop();
                g(m, n, i, h, e)
            }
        }
    } else {
        if (b._id && !EJSON.equals(a._id, b._id))
            throw Error("Cannot change the _id of a document");
        for (var d in b) {
            if ("$" === d.substr(0, 1))
                throw Error("When replacing document, field name may not start with '$'");
            if (/\./.test(d))
                throw Error("When replacing document, field name may not contain '.'")
        }
        e = b
    }
    _.each(_.keys(a), function(b) {
        "_id" !== b && delete a[b]
    });
    for (var d in e)
        a[d] = e[d]
}, LocalCollection._findModTarget = function(a, b, c, d) {
    for (var e = 0; e < b.length; e++) {
        var f = e === b.length - 1, g = b[e], h = /^[0-9]+$/.test(g);
        if (!(!c || "object" == typeof a && g in a))
            return void 0;
        if (a instanceof Array) {
            if (d)
                return null;
            if (!h)
                throw Error("can't append to array using string field name [" + g + "]");
            for (g = parseInt(g), f && (b[e] = g); a.length < g; )
                a.push(null);
            if (!f)
                if (a.length === g)
                    a.push({});
                else if ("object" != typeof a[g])
                    throw Error("can't modify field '" + b[e + 1] + "' of list value " + JSON.stringify(a[g]))
        } else
            f || g in a || (a[g] = {});
        if (f)
            return a;
        a = a[g]
    }
}, LocalCollection._noCreateModifiers = {$unset: !0,$pop: !0,$rename: !0,$pull: !0,$pullAll: !0}, LocalCollection._modifiers = {$inc: function(a, b, c) {
        if ("number" != typeof c)
            throw Error("Modifier $inc allowed for numbers only");
        if (b in a) {
            if ("number" != typeof a[b])
                throw Error("Cannot apply $inc modifier to non-number");
            a[b] += c
        } else
            a[b] = c
    },$set: function(a, b, c) {
        if ("_id" === b && !EJSON.equals(c, a._id))
            throw Error("Cannot change the _id of a document");
        a[b] = EJSON.clone(c)
    },$unset: function(a, b) {
        void 0 !== a && (a instanceof Array ? b in a && (a[b] = null) : delete a[b])
    },$push: function(a, b, c) {
        var d = a[b];
        if (void 0 === d)
            a[b] = [c];
        else {
            if (!(d instanceof Array))
                throw Error("Cannot apply $push modifier to non-array");
            d.push(EJSON.clone(c))
        }
    },$pushAll: function(a, b, c) {
        if (!("object" == typeof c && c instanceof Array))
            throw Error("Modifier $pushAll/pullAll allowed for arrays only");
        var d = a[b];
        if (void 0 === d)
            a[b] = c;
        else {
            if (!(d instanceof Array))
                throw Error("Cannot apply $pushAll modifier to non-array");
            for (var e = 0; e < c.length; e++)
                d.push(c[e])
        }
    },$addToSet: function(a, b, c) {
        var d = a[b];
        if (void 0 === d)
            a[b] = [c];
        else {
            if (!(d instanceof Array))
                throw Error("Cannot apply $addToSet modifier to non-array");
            var e = !1;
            if ("object" == typeof c)
                for (var f in c) {
                    "$each" === f && (e = !0);
                    break
                }
            var g = e ? c.$each : [c];
            _.each(g, function(a) {
                for (var b = 0; b < d.length; b++)
                    if (LocalCollection._f._equal(a, d[b]))
                        return;
                d.push(a)
            })
        }
    },$pop: function(a, b, c) {
        if (void 0 !== a) {
            var d = a[b];
            if (void 0 !== d) {
                if (!(d instanceof Array))
                    throw Error("Cannot apply $pop modifier to non-array");
                "number" == typeof c && 0 > c ? d.splice(0, 1) : d.pop()
            }
        }
    },$pull: function(a, b, c) {
        if (void 0 !== a) {
            var d = a[b];
            if (void 0 !== d) {
                if (!(d instanceof Array))
                    throw Error("Cannot apply $pull/pullAll modifier to non-array");
                var e = [];
                if ("object" != typeof c || c instanceof Array)
                    for (var f = 0; f < d.length; f++)
                        LocalCollection._f._equal(d[f], c) || e.push(d[f]);
                else
                    for (var g = LocalCollection._compileSelector(c), f = 0; f < d.length; f++)
                        g(d[f]) || e.push(d[f]);
                a[b] = e
            }
        }
    },$pullAll: function(a, b, c) {
        if (!("object" == typeof c && c instanceof Array))
            throw Error("Modifier $pushAll/pullAll allowed for arrays only");
        if (void 0 !== a) {
            var d = a[b];
            if (void 0 !== d) {
                if (!(d instanceof Array))
                    throw Error("Cannot apply $pull/pullAll modifier to non-array");
                for (var e = [], f = 0; f < d.length; f++) {
                    for (var g = !1, h = 0; h < c.length; h++)
                        if (LocalCollection._f._equal(d[f], c[h])) {
                            g = !0;
                            break
                        }
                    g || e.push(d[f])
                }
                a[b] = e
            }
        }
    },$rename: function(a, b, c, d, e) {
        if (d === c)
            throw Error("$rename source must differ from target");
        if (null === a)
            throw Error("$rename source field invalid");
        if ("string" != typeof c)
            throw Error("$rename target must be a string");
        if (void 0 !== a) {
            var f = a[b];
            delete a[b];
            var g = c.split("."), h = LocalCollection._findModTarget(e, g, !1, !0);
            if (null === h)
                throw Error("$rename target field invalid");
            var i = g.pop();
            h[i] = f
        }
    },$bit: function() {
        throw Error("$bit is not supported")
    }}, LocalCollection._diffQueryChanges = function(a, b, c, d) {
    a ? LocalCollection._diffQueryOrderedChanges(b, c, d) : LocalCollection._diffQueryUnorderedChanges(b, c, d)
}, LocalCollection._diffQueryUnorderedChanges = function(a, b, c) {
    if (c.moved)
        throw new Error("_diffQueryUnordered called with a moved observer!");
    _.each(b, function(b) {
        if (_.has(a, b._id)) {
            var d = a[b._id];
            c.changed && !EJSON.equals(d, b) && c.changed(b._id, LocalCollection._makeChangedFields(b, d))
        } else {
            var e = EJSON.clone(b);
            delete e._id, c.added && c.added(b._id, e)
        }
    }), c.removed && _.each(a, function(a) {
        _.has(b, a._id) || c.removed(a._id)
    })
}, LocalCollection._diffQueryOrderedChanges = function(a, b, c) {
    var d = {};
    _.each(b, function(a) {
        d[a._id] && Meteor._debug("Duplicate _id in new_results"), d[a._id] = !0
    });
    var e = {};
    _.each(a, function(a, b) {
        a._id in e && Meteor._debug("Duplicate _id in old_results"), e[a._id] = b
    });
    for (var f = [], g = 0, h = b.length, i = new Array(h), j = new Array(h), k = function(a) {
        return e[b[a]._id]
    }, l = 0; h > l; l++)
        if (void 0 !== e[b[l]._id]) {
            for (var m = g; m > 0 && !(k(i[m - 1]) < k(l)); )
                m--;
            j[l] = 0 === m ? -1 : i[m - 1], i[m] = l, m + 1 > g && (g = m + 1)
        }
    for (var n = 0 === g ? -1 : i[g - 1]; n >= 0; )
        f.push(n), n = j[n];
    f.reverse(), f.push(b.length), _.each(a, function(a) {
        d[a._id] || c.removed && c.removed(a._id)
    });
    var o = 0;
    _.each(f, function(d) {
        for (var f, g, h, i = b[d] ? b[d]._id : null, j = o; d > j; j++)
            g = b[j], _.has(e, g._id) ? (f = a[e[g._id]], h = LocalCollection._makeChangedFields(g, f), _.isEmpty(h) || c.changed && c.changed(g._id, h), c.movedBefore && c.movedBefore(g._id, i)) : (h = EJSON.clone(g), delete h._id, c.addedBefore && c.addedBefore(g._id, h, i), c.added && c.added(g._id, h));
        i && (g = b[d], f = a[e[g._id]], h = LocalCollection._makeChangedFields(g, f), _.isEmpty(h) || c.changed && c.changed(g._id, h)), o = d + 1
    })
}, LocalCollection._diffObjects = function(a, b, c) {
    _.each(a, function(a, d) {
        _.has(b, d) ? c.both && c.both(d, a, b[d]) : c.leftOnly && c.leftOnly(d, a)
    }), c.rightOnly && _.each(b, function(b, d) {
        _.has(a, d) || c.rightOnly(d, b)
    })
}, LocalCollection._looksLikeObjectID = function(a) {
    return 24 === a.length && a.match(/^[0-9a-f]*$/)
}, LocalCollection._ObjectID = function(a) {
    var b = this;
    if (a) {
        if (a = a.toLowerCase(), !LocalCollection._looksLikeObjectID(a))
            throw new Error("Invalid hexadecimal string for creating an ObjectID");
        b._str = a
    } else
        b._str = Random.hexString(24)
}, LocalCollection._ObjectID.prototype.toString = function() {
    var a = this;
    return 'ObjectID("' + a._str + '")'
}, LocalCollection._ObjectID.prototype.equals = function(a) {
    var b = this;
    return a instanceof LocalCollection._ObjectID && b.valueOf() === a.valueOf()
}, LocalCollection._ObjectID.prototype.clone = function() {
    var a = this;
    return new LocalCollection._ObjectID(a._str)
}, LocalCollection._ObjectID.prototype.typeName = function() {
    return "oid"
}, LocalCollection._ObjectID.prototype.getTimestamp = function() {
    var a = this;
    return parseInt(a._str.substr(0, 8), 16)
}, LocalCollection._ObjectID.prototype.valueOf = LocalCollection._ObjectID.prototype.toJSONValue = LocalCollection._ObjectID.prototype.toHexString = function() {
    return this._str
}, LocalCollection._selectorIsId = function(a) {
    return "string" == typeof a || "number" == typeof a || a instanceof LocalCollection._ObjectID
}, LocalCollection._selectorIsIdPerhapsAsObject = function(a) {
    return LocalCollection._selectorIsId(a) || a && "object" == typeof a && a._id && LocalCollection._selectorIsId(a._id) && 1 === _.size(a)
}, LocalCollection._idsMatchedBySelector = function(a) {
    if (LocalCollection._selectorIsId(a))
        return [a];
    if (!a)
        return null;
    if (_.has(a, "_id"))
        return LocalCollection._selectorIsId(a._id) ? [a._id] : a._id && a._id.$in && _.isArray(a._id.$in) && !_.isEmpty(a._id.$in) && _.all(a._id.$in, LocalCollection._selectorIsId) ? a._id.$in : null;
    if (a.$and && _.isArray(a.$and))
        for (var b = 0; b < a.$and.length; ++b) {
            var c = LocalCollection._idsMatchedBySelector(a.$and[b]);
            if (c)
                return c
        }
    return null
}, EJSON.addType("oid", function(a) {
    return new LocalCollection._ObjectID(a)
}), Meteor._SUPPORTED_DDP_VERSIONS = ["pre1"], Meteor._MethodInvocation = function(a) {
    this.isSimulation = a.isSimulation, this.is_simulation = this.isSimulation, this._unblock = a.unblock || function() {
    }, this._calledUnblock = !1, this.userId = a.userId, this._setUserId = a.setUserId || function() {
    }, this._sessionData = a.sessionData
}, _.extend(Meteor._MethodInvocation.prototype, {unblock: function() {
        var a = this;
        a._calledUnblock = !0, a._unblock()
    },setUserId: function(a) {
        var b = this;
        if (b._calledUnblock)
            throw new Error("Can't call setUserId in a method after calling unblock");
        b.userId = a, b._setUserId(a)
    }}), Meteor._parseDDP = function(a) {
    try {
        var b = JSON.parse(a)
    } catch (c) {
        return Meteor._debug("Discarding message with invalid JSON", a), null
    }
    return null === b || "object" != typeof b ? (Meteor._debug("Discarding non-object DDP message", a), null) : (_.has(b, "cleared") && (_.has(b, "fields") || (b.fields = {}), _.each(b.cleared, function(a) {
        b.fields[a] = void 0
    }), delete b.cleared), _.each(["fields", "params", "result"], function(a) {
        _.has(b, a) && (b[a] = EJSON._adjustTypesFromJSONValue(b[a]))
    }), b)
}, Meteor._stringifyDDP = function(a) {
    var b = EJSON.clone(a);
    if (_.has(a, "fields")) {
        var c = [];
        _.each(a.fields, function(a, d) {
            void 0 === a && (c.push(d), delete b.fields[d])
        }), _.isEmpty(c) || (b.cleared = c), _.isEmpty(b.fields) && delete b.fields
    }
    if (_.each(["fields", "params", "result"], function(a) {
        _.has(b, a) && (b[a] = EJSON._adjustTypesToJSONValue(b[a]))
    }), a.id && "string" != typeof a.id)
        throw new Error("Message id is not a string");
    return JSON.stringify(b)
}, Meteor._CurrentInvocation = new Meteor.EnvironmentVariable, Meteor.Error = Meteor.makeErrorType("Meteor.Error", function(a, b, c) {
    var d = this;
    d.error = a, d.reason = b, d.details = c, d.message = d.reason ? d.reason + " [" + d.error + "]" : "[" + d.error + "]"
}), Meteor.isServer)
    var path = Npm.require("path"), Fiber = Npm.require("fibers"), Future = Npm.require(path.join("fibers", "future"));
Meteor._LivedataConnection = function(a, b) {
    var c = this;
    b = _.extend({reloadOnUpdate: !1,reloadWithOutstanding: !1,supportedDDPVersions: Meteor._SUPPORTED_DDP_VERSIONS,onConnectionFailure: function(a) {
            Meteor._debug("Failed DDP connection: " + a)
        },onConnected: function() {
        }}, b), c.onReconnect = null, c._stream = "object" == typeof a ? a : new Meteor._DdpClientStream(a), c._lastSessionId = null, c._versionSuggestion = null, c._version = null, c._stores = {}, c._methodHandlers = {}, c._nextMethodId = 1, c._supportedDDPVersions = b.supportedDDPVersions, c._methodInvokers = {}, c._outstandingMethodBlocks = [], c._documentsWrittenByStub = {}, c._serverDocuments = {}, c._afterUpdateCallbacks = [], c._messagesBufferedUntilQuiescence = [], c._methodsBlockingQuiescence = {}, c._subsBeingRevived = {}, c._resetStores = !1, c._updatesForUnknownStores = {}, c._retryMigrate = null, c._subscriptions = {}, c._sessionData = {}, c._userId = null, c._userIdDeps = "undefined" != typeof Deps && new Deps.Dependency, Meteor._reload && !b.reloadWithOutstanding && Meteor._reload.onMigrate(function(a) {
        if (c._readyToMigrate())
            return [!0];
        if (c._retryMigrate)
            throw new Error("Two migrations in progress?");
        return c._retryMigrate = a, !1
    });
    var d = function(a) {
        try {
            var d = Meteor._parseDDP(a)
        } catch (e) {
            return Meteor._debug("Exception while parsing DDP", e), void 0
        }
        if (null === d || !d.msg)
            return Meteor._debug("discarding invalid livedata message", d), void 0;
        if ("connected" === d.msg)
            c._version = c._versionSuggestion, b.onConnected(), c._livedata_connected(d);
        else if ("failed" == d.msg)
            if (_.contains(c._supportedDDPVersions, d.version))
                c._versionSuggestion = d.version, c._stream.reconnect({_force: !0});
            else {
                var f = "Version negotiation failed; server requested version " + d.version;
                c._stream.forceDisconnect(f), b.onConnectionFailure(f)
            }
        else
            _.include(["added", "changed", "removed", "ready", "updated"], d.msg) ? c._livedata_data(d) : "nosub" === d.msg ? c._livedata_nosub(d) : "result" === d.msg ? c._livedata_result(d) : "error" === d.msg ? c._livedata_error(d) : Meteor._debug("discarding unknown livedata message type", d)
    }, e = function() {
        var a = {msg: "connect"};
        c._lastSessionId && (a.session = c._lastSessionId), a.version = c._versionSuggestion || c._supportedDDPVersions[0], c._versionSuggestion = a.version, a.support = c._supportedDDPVersions, c._send(a), !_.isEmpty(c._outstandingMethodBlocks) && _.isEmpty(c._outstandingMethodBlocks[0].methods) && c._outstandingMethodBlocks.shift(), _.each(c._methodInvokers, function(a) {
            a.sentMessage = !1
        }), c.onReconnect ? c._callOnReconnectAndSendAppropriateOutstandingMethods() : c._sendOutstandingMethods(), _.each(c._subscriptions, function(a, b) {
            c._send({msg: "sub",id: b,name: a.name,params: a.params})
        })
    };
    Meteor.isServer ? (c._stream.on("message", Meteor.bindEnvironment(d, Meteor._debug)), c._stream.on("reset", Meteor.bindEnvironment(e, Meteor._debug))) : (c._stream.on("message", d), c._stream.on("reset", e)), Meteor._reload && b.reloadOnUpdate && c._stream.on("update_available", function() {
        Meteor._reload.reload()
    })
};
var MethodInvoker = function(a) {
    var b = this;
    b.methodId = a.methodId, b.sentMessage = !1, b._callback = a.callback, b._connection = a.connection, b._message = a.message, b._onResultReceived = a.onResultReceived || function() {
    }, b._wait = a.wait, b._methodResult = null, b._dataVisible = !1, b._connection._methodInvokers[b.methodId] = b
};
if (_.extend(MethodInvoker.prototype, {sendMessage: function() {
        var a = this;
        if (a.gotResult())
            throw new Error("sendingMethod is called on method with result");
        a._dataVisible = !1, a.sentMessage = !0, a._wait && (a._connection._methodsBlockingQuiescence[a.methodId] = !0), a._connection._send(a._message)
    },_maybeInvokeCallback: function() {
        var a = this;
        a._methodResult && a._dataVisible && (a._callback(a._methodResult[0], a._methodResult[1]), delete a._connection._methodInvokers[a.methodId], a._connection._outstandingMethodFinished())
    },receiveResult: function(a, b) {
        var c = this;
        if (c.gotResult())
            throw new Error("Methods should only receive results once");
        c._methodResult = [a, b], c._onResultReceived(a, b), c._maybeInvokeCallback()
    },dataVisible: function() {
        var a = this;
        a._dataVisible = !0, a._maybeInvokeCallback()
    },gotResult: function() {
        var a = this;
        return !!a._methodResult
    }}), _.extend(Meteor._LivedataConnection.prototype, {registerStore: function(a, b) {
        var c = this;
        if (a in c._stores)
            return !1;
        var d = {};
        _.each(["update", "beginUpdate", "endUpdate", "saveOriginals", "retrieveOriginals"], function(a) {
            d[a] = function() {
                return b[a] ? b[a].apply(b, arguments) : void 0
            }
        }), c._stores[a] = d;
        var e = c._updatesForUnknownStores[a];
        return e && (d.beginUpdate(e.length, !1), _.each(e, function(a) {
            d.update(a)
        }), d.endUpdate(), delete c._updatesForUnknownStores[a]), !0
    },subscribe: function(a) {
        var b = this, c = Array.prototype.slice.call(arguments, 1), d = {};
        if (c.length) {
            var e = c[c.length - 1];
            "function" == typeof e ? d.onReady = c.pop() : !e || "function" != typeof e.onReady && "function" != typeof e.onError || (d = c.pop())
        }
        var f, g = _.find(b._subscriptions, function(b) {
            return b.inactive && b.name === a && EJSON.equals(b.params, c)
        });
        g ? (f = g.id, g.inactive = !1, d.onReady && (g.ready || (g.readyCallback = d.onReady)), d.onError && (g.errorCallback = d.onError)) : (f = Random.id(), b._subscriptions[f] = {id: f,name: a,params: c,inactive: !1,ready: !1,readyDeps: "undefined" != typeof Deps && new Deps.Dependency,readyCallback: d.onReady,errorCallback: d.onError}, b._send({msg: "sub",id: f,name: a,params: c}));
        var h = {stop: function() {
                _.has(b._subscriptions, f) && (b._send({msg: "unsub",id: f}), delete b._subscriptions[f])
            },ready: function() {
                if (!_.has(b._subscriptions, f))
                    return !1;
                var a = b._subscriptions[f];
                return a.readyDeps && a.readyDeps.depend(), a.ready
            }};
        return Deps.active && Deps.onInvalidate(function() {
            _.has(b._subscriptions, f) && (b._subscriptions[f].inactive = !0), Deps.afterFlush(function() {
                _.has(b._subscriptions, f) && b._subscriptions[f].inactive && h.stop()
            })
        }), h
    },methods: function(a) {
        var b = this;
        _.each(a, function(a, c) {
            if (b._methodHandlers[c])
                throw new Error("A method named '" + c + "' is already defined");
            b._methodHandlers[c] = a
        })
    },call: function(a) {
        var b = Array.prototype.slice.call(arguments, 1);
        if (b.length && "function" == typeof b[b.length - 1])
            var c = b.pop();
        return this.apply(a, b, c)
    },apply: function(a, b, c, d) {
        var e = this;
        d || "function" != typeof c || (d = c, c = {}), c = c || {}, d && (d = Meteor.bindEnvironment(d, function(b) {
            Meteor._debug("Exception while delivering result of invoking '" + a + "'", b, b.stack)
        }));
        var f = function() {
            var a;
            return function() {
                return void 0 === a && (a = "" + e._nextMethodId++), a
            }
        }(), g = Meteor._CurrentInvocation.get(), h = g && g.isSimulation, i = e._methodHandlers[a];
        if (i) {
            var j = function(a) {
                e.setUserId(a)
            }, k = new Meteor._MethodInvocation({isSimulation: !0,userId: e.userId(),setUserId: j,sessionData: e._sessionData});
            h || e._saveOriginals();
            try {
                var l = Meteor._CurrentInvocation.withValue(k, function() {
                    return Meteor.isServer ? Meteor._noYieldsAllowed(function() {
                        return i.apply(k, EJSON.clone(b))
                    }) : i.apply(k, EJSON.clone(b))
                })
            } catch (m) {
                var n = m
            }
            h || e._retrieveAndStoreOriginals(f())
        }
        if (h) {
            if (d)
                return d(n, l), void 0;
            if (n)
                throw n;
            return l
        }
        if (n && !n.expected && Meteor._debug("Exception while simulating the effect of invoking '" + a + "'", n, n.stack), !d)
            if (Meteor.isClient)
                d = function() {
                };
            else {
                var o = new Future;
                d = function(a, b) {
                    a ? o["throw"](a) : o["return"](b)
                }
            }
        var p = new MethodInvoker({methodId: f(),callback: d,connection: e,onResultReceived: c.onResultReceived,wait: !!c.wait,message: {msg: "method",method: a,params: b,id: f()}});
        return c.wait ? e._outstandingMethodBlocks.push({wait: !0,methods: [p]}) : ((_.isEmpty(e._outstandingMethodBlocks) || _.last(e._outstandingMethodBlocks).wait) && e._outstandingMethodBlocks.push({wait: !1,methods: []}), _.last(e._outstandingMethodBlocks).methods.push(p)), 1 === e._outstandingMethodBlocks.length && p.sendMessage(), o ? o.wait() : void 0
    },_saveOriginals: function() {
        var a = this;
        _.each(a._stores, function(a) {
            a.saveOriginals()
        })
    },_retrieveAndStoreOriginals: function(a) {
        var b = this;
        if (b._documentsWrittenByStub[a])
            throw new Error("Duplicate methodId in _retrieveAndStoreOriginals");
        var c = [];
        _.each(b._stores, function(d, e) {
            var f = d.retrieveOriginals();
            _.each(f, function(d, f) {
                if ("string" != typeof f)
                    throw new Error("id is not a string");
                c.push({collection: e,id: f});
                var g = Meteor._ensure(b._serverDocuments, e, f);
                g.writtenByStubs ? g.writtenByStubs[a] = !0 : (g.document = d, g.flushCallbacks = [], g.writtenByStubs = {}, g.writtenByStubs[a] = !0)
            })
        }), _.isEmpty(c) || (b._documentsWrittenByStub[a] = c)
    },_unsubscribeAll: function() {
        var a = this;
        _.each(_.clone(a._subscriptions), function(b, c) {
            a._send({msg: "unsub",id: c}), delete a._subscriptions[c]
        })
    },_send: function(a) {
        var b = this;
        b._stream.send(Meteor._stringifyDDP(a))
    },status: function() {
        var a = this;
        return a._stream.status.apply(a._stream, arguments)
    },reconnect: function() {
        var a = this;
        return a._stream.reconnect.apply(a._stream, arguments)
    },userId: function() {
        var a = this;
        return a._userIdDeps && a._userIdDeps.depend(), a._userId
    },setUserId: function(a) {
        var b = this;
        b._userId !== a && (b._userId = a, b._userIdDeps && b._userIdDeps.changed())
    },_waitingForQuiescence: function() {
        var a = this;
        return !_.isEmpty(a._subsBeingRevived) || !_.isEmpty(a._methodsBlockingQuiescence)
    },_anyMethodsAreOutstanding: function() {
        var a = this;
        return _.any(_.pluck(a._methodInvokers, "sentMessage"))
    },_livedata_connected: function(a) {
        var b = this;
        if (b._lastSessionId && (b._resetStores = !0), "string" == typeof a.session) {
            var c = b._lastSessionId === a.session;
            b._lastSessionId = a.session
        }
        c || (b._updatesForUnknownStores = {}, b._resetStores && (b._documentsWrittenByStub = {}, b._serverDocuments = {}), b._afterUpdateCallbacks = [], b._subsBeingRevived = {}, _.each(b._subscriptions, function(a, c) {
            a.ready && (b._subsBeingRevived[c] = !0)
        }), b._methodsBlockingQuiescence = {}, b._resetStores && _.each(b._methodInvokers, function(a) {
            a.gotResult() ? b._afterUpdateCallbacks.push(_.bind(a.dataVisible, a)) : a.sentMessage && (b._methodsBlockingQuiescence[a.methodId] = !0)
        }), b._messagesBufferedUntilQuiescence = [], b._waitingForQuiescence() || (b._resetStores && (_.each(b._stores, function(a) {
            a.beginUpdate(0, !0), a.endUpdate()
        }), b._resetStores = !1), b._runAfterUpdateCallbacks()))
    },_processOneDataMessage: function(a, b) {
        var c = this;
        c["_process_" + a.msg](a, b)
    },_livedata_data: function(a) {
        var b = this, c = {};
        if (b._waitingForQuiescence()) {
            if (b._messagesBufferedUntilQuiescence.push(a), _.each(a.subs || [], function(a) {
                delete b._subsBeingRevived[a]
            }), _.each(a.methods || [], function(a) {
                delete b._methodsBlockingQuiescence[a]
            }), b._waitingForQuiescence())
                return;
            _.each(b._messagesBufferedUntilQuiescence, function(a) {
                b._processOneDataMessage(a, c)
            }), b._messagesBufferedUntilQuiescence = []
        } else
            b._processOneDataMessage(a, c);
        (b._resetStores || !_.isEmpty(c)) && (_.each(b._stores, function(a, d) {
            a.beginUpdate(_.has(c, d) ? c[d].length : 0, b._resetStores)
        }), b._resetStores = !1, _.each(c, function(a, c) {
            var d = b._stores[c];
            d ? _.each(a, function(a) {
                d.update(a)
            }) : (_.has(b._updatesForUnknownStores, c) || (b._updatesForUnknownStores[c] = []), Array.prototype.push.apply(b._updatesForUnknownStores[c], a))
        }), _.each(b._stores, function(a) {
            a.endUpdate()
        })), b._runAfterUpdateCallbacks()
    },_runAfterUpdateCallbacks: function() {
        var a = this, b = a._afterUpdateCallbacks;
        a._afterUpdateCallbacks = [], _.each(b, function(a) {
            a()
        })
    },_pushUpdate: function(a, b, c) {
        _.has(a, b) || (a[b] = []), a[b].push(c)
    },_process_added: function(a, b) {
        var c = this, d = Meteor._get(c._serverDocuments, a.collection, a.id);
        if (d) {
            if (void 0 !== d.document)
                throw new Error("It doesn't make sense to be adding something we know exists: " + a.id);
            d.document = a.fields || {}, d.document._id = Meteor.idParse(a.id)
        } else
            c._pushUpdate(b, a.collection, a)
    },_process_changed: function(a, b) {
        var c = this, d = Meteor._get(c._serverDocuments, a.collection, a.id);
        if (d) {
            if (void 0 === d.document)
                throw new Error("It doesn't make sense to be changing something we don't think exists: " + a.id);
            LocalCollection._applyChanges(d.document, a.fields)
        } else
            c._pushUpdate(b, a.collection, a)
    },_process_removed: function(a, b) {
        var c = this, d = Meteor._get(c._serverDocuments, a.collection, a.id);
        if (d) {
            if (void 0 === d.document)
                throw new Error("It doesn't make sense to be deleting something we don't know exists: " + a.id);
            d.document = void 0
        } else
            c._pushUpdate(b, a.collection, {msg: "removed",collection: a.collection,id: a.id})
    },_process_updated: function(a, b) {
        var c = this;
        _.each(a.methods, function(a) {
            _.each(c._documentsWrittenByStub[a], function(d) {
                var e = Meteor._get(c._serverDocuments, d.collection, d.id);
                if (!e)
                    throw new Error("Lost serverDoc for " + JSON.stringify(d));
                if (!e.writtenByStubs[a])
                    throw new Error("Doc " + JSON.stringify(d) + " not written by  method " + a);
                delete e.writtenByStubs[a], _.isEmpty(e.writtenByStubs) && (c._pushUpdate(b, d.collection, {msg: "replace",id: d.id,replace: e.document}), _.each(e.flushCallbacks, function(a) {
                    a()
                }), delete c._serverDocuments[d.collection][d.id])
            }), delete c._documentsWrittenByStub[a];
            var d = c._methodInvokers[a];
            if (!d)
                throw new Error("No callback invoker for method " + a);
            c._runWhenAllServerDocsAreFlushed(_.bind(d.dataVisible, d))
        })
    },_process_ready: function(a) {
        var b = this;
        _.each(a.subs, function(a) {
            b._runWhenAllServerDocsAreFlushed(function() {
                var c = b._subscriptions[a];
                c && (c.ready || (c.readyCallback && c.readyCallback(), c.ready = !0, c.readyDeps && c.readyDeps.changed()))
            })
        })
    },_runWhenAllServerDocsAreFlushed: function(a) {
        var b = this, c = function() {
            b._afterUpdateCallbacks.push(a)
        }, d = 0, e = function() {
            --d, 0 === d && c()
        };
        _.each(b._serverDocuments, function(a) {
            _.each(a, function(a) {
                var c = _.any(a.writtenByStubs, function(a, c) {
                    var d = b._methodInvokers[c];
                    return d && d.sentMessage
                });
                c && (++d, a.flushCallbacks.push(e))
            })
        }), 0 === d && c()
    },_livedata_nosub: function(a) {
        var b = this;
        if (_.has(b._subscriptions, a.id)) {
            var c = b._subscriptions[a.id].errorCallback;
            delete b._subscriptions[a.id], c && a.error && c(new Meteor.Error(a.error.error, a.error.reason, a.error.details))
        }
    },_livedata_result: function(a) {
        var b = this;
        if (_.isEmpty(b._outstandingMethodBlocks))
            return Meteor._debug("Received method result but no methods outstanding"), void 0;
        for (var c, d = b._outstandingMethodBlocks[0].methods, e = 0; e < d.length && (c = d[e], c.methodId !== a.id); e++)
            ;
        return c ? (d.splice(e, 1), _.has(a, "error") ? c.receiveResult(new Meteor.Error(a.error.error, a.error.reason, a.error.details)) : c.receiveResult(void 0, a.result), void 0) : (Meteor._debug("Can't match method response to original method call", a), void 0)
    },_outstandingMethodFinished: function() {
        var a = this;
        if (!a._anyMethodsAreOutstanding()) {
            if (!_.isEmpty(a._outstandingMethodBlocks)) {
                var b = a._outstandingMethodBlocks.shift();
                if (!_.isEmpty(b.methods))
                    throw new Error("No methods outstanding but nonempty block: " + JSON.stringify(b));
                _.isEmpty(a._outstandingMethodBlocks) || a._sendOutstandingMethods()
            }
            a._maybeMigrate()
        }
    },_sendOutstandingMethods: function() {
        var a = this;
        _.isEmpty(a._outstandingMethodBlocks) || _.each(a._outstandingMethodBlocks[0].methods, function(a) {
            a.sendMessage()
        })
    },_livedata_error: function(a) {
        Meteor._debug("Received error from server: ", a.reason), a.offendingMessage && Meteor._debug("For: ", a.offendingMessage)
    },_callOnReconnectAndSendAppropriateOutstandingMethods: function() {
        var a = this, b = a._outstandingMethodBlocks;
        if (a._outstandingMethodBlocks = [], a.onReconnect(), !_.isEmpty(b)) {
            if (_.isEmpty(a._outstandingMethodBlocks))
                return a._outstandingMethodBlocks = b, a._sendOutstandingMethods(), void 0;
            _.last(a._outstandingMethodBlocks).wait || b[0].wait || (_.each(b[0].methods, function(b) {
                _.last(a._outstandingMethodBlocks).methods.push(b), 1 === a._outstandingMethodBlocks.length && b.sendMessage()
            }), b.shift()), _.each(b, function(b) {
                a._outstandingMethodBlocks.push(b)
            })
        }
    },_readyToMigrate: function() {
        var a = this;
        return _.isEmpty(a._methodInvokers)
    },_maybeMigrate: function() {
        var a = this;
        a._retryMigrate && a._readyToMigrate() && (a._retryMigrate(), a._retryMigrate = null)
    }}), _.extend(Meteor, {connect: function(a, b) {
        var c = new Meteor._LivedataConnection(a, {reloadOnUpdate: b});
        return Meteor._LivedataConnection._allConnections.push(c), c
    }}), Meteor._LivedataConnection._allConnections = [], Meteor._LivedataConnection._allSubscriptionsReady = function() {
    return _.all(Meteor._LivedataConnection._allConnections, function(a) {
        return _.all(a._subscriptions, function(a) {
            return a.ready
        })
    })
}, _.extend(Meteor, {default_connection: null,refresh: function() {
    }}), Meteor.isClient) {
    var ddpUrl = "/";
    "undefined" != typeof __meteor_runtime_config__ && __meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL && (ddpUrl = __meteor_runtime_config__.DDP_DEFAULT_CONNECTION_URL)
}
Meteor._LocalCollectionDriver = function() {
    var a = this;
    a.collections = {}
}, _.extend(Meteor._LocalCollectionDriver.prototype, {open: function(a) {
        var b = this;
        return a ? (a in b.collections || (b.collections[a] = new LocalCollection), b.collections[a]) : new LocalCollection
    }}), Meteor._LocalCollectionDriver = new Meteor._LocalCollectionDriver, Meteor.Collection = function(a, b) {
    var c = this;
    if (!(c instanceof Meteor.Collection))
        throw new Error('use "new" to construct a Meteor.Collection');
    switch (b && b.methods && (b = {connection: b}), b && b.manager && !b.connection && (b.connection = b.manager), b = _.extend({connection: void 0,idGeneration: "STRING",transform: null,_driver: void 0,_preventAutopublish: !1}, b), b.idGeneration) {
        case "MONGO":
            c._makeNewID = function() {
                return new Meteor.Collection.ObjectID
            };
            break;
        case "STRING":
        default:
            c._makeNewID = function() {
                return Random.id()
            }
    }
    if (c._transform = b.transform ? Deps._makeNonreactive(b.transform) : null, a || null === a || Meteor._debug("Warning: creating anonymous collection. It will not be saved or synchronized over the network. (Pass null for the collection name to turn off this warning.)"), c._connection = a && (b.connection || (Meteor.isClient ? Meteor.default_connection : Meteor.default_server)), b._driver || (b._driver = a && c._connection === Meteor.default_server && Meteor._RemoteCollectionDriver ? Meteor._RemoteCollectionDriver : Meteor._LocalCollectionDriver), c._collection = b._driver.open(a), c._name = a, a && c._connection.registerStore) {
        var d = c._connection.registerStore(a, {beginUpdate: function(a, b) {
                (a > 1 || b) && c._collection.pauseObservers(), b && c._collection.remove({})
            },update: function(a) {
                var b = Meteor.idParse(a.id), d = c._collection.findOne(b);
                if ("replace" === a.msg) {
                    var e = a.replace;
                    return e ? d ? c._collection.update(b, e) : c._collection.insert(e) : d && c._collection.remove(b), void 0
                }
                if ("added" === a.msg) {
                    if (d)
                        throw new Error("Expected not to find a document already present for an add");
                    c._collection.insert(_.extend({_id: b}, a.fields))
                } else if ("removed" === a.msg) {
                    if (!d)
                        throw new Error("Expected to find a document already present for removed");
                    c._collection.remove(b)
                } else {
                    if ("changed" !== a.msg)
                        throw new Error("I don't know how to deal with this message");
                    if (!d)
                        throw new Error("Expected to find a document to change");
                    if (!_.isEmpty(a.fields)) {
                        var f = {};
                        _.each(a.fields, function(a, b) {
                            void 0 === a ? (f.$unset || (f.$unset = {}), f.$unset[b] = 1) : (f.$set || (f.$set = {}), f.$set[b] = a)
                        }), c._collection.update(b, f)
                    }
                }
            },endUpdate: function() {
                c._collection.resumeObservers()
            },saveOriginals: function() {
                c._collection.saveOriginals()
            },retrieveOriginals: function() {
                return c._collection.retrieveOriginals()
            }});
        if (!d)
            throw new Error("There is already a collection named '" + a + "'")
    }
    c._defineMutationMethods(), !b._preventAutopublish && c._connection && c._connection.onAutopublish && c._connection.onAutopublish(function() {
        var a = function() {
            return c.find()
        };
        c._connection.publish(null, a, {is_auto: !0})
    })
}, _.extend(Meteor.Collection.prototype, {_getFindSelector: function(a) {
        return 0 == a.length ? {} : a[0]
    },_getFindOptions: function(a) {
        var b = this;
        return a.length < 2 ? {transform: b._transform} : _.extend({transform: b._transform}, a[1])
    },find: function() {
        var a = this, b = _.toArray(arguments);
        return a._collection.find(a._getFindSelector(b), a._getFindOptions(b))
    },findOne: function() {
        var a = this, b = _.toArray(arguments);
        return a._collection.findOne(a._getFindSelector(b), a._getFindOptions(b))
    }}), Meteor.Collection._rewriteSelector = function(a) {
    if (LocalCollection._selectorIsId(a) && (a = {_id: a}), !a || "_id" in a && !a._id)
        return {_id: Random.id()};
    var b = {};
    return _.each(a, function(a, c) {
        if (a instanceof RegExp) {
            b[c] = {$regex: a.source};
            var d = "";
            a.ignoreCase && (d += "i"), a.multiline && (d += "m"), d && (b[c].$options = d)
        } else
            b[c] = a
    }), b
};
var throwIfSelectorIsNotId = function(a, b) {
    if (!LocalCollection._selectorIsIdPerhapsAsObject(a))
        throw new Meteor.Error(403, "Not permitted. Untrusted code may only " + b + " documents by ID.")
};
_.each(["insert", "update", "remove"], function(a) {
    Meteor.Collection.prototype[a] = function() {
        var b, c, d = this, e = _.toArray(arguments);
        if (e.length && e[e.length - 1] instanceof Function && (b = e.pop()), Meteor.isClient && !b && (b = function(b) {
            b && Meteor._debug(a + " failed: " + (b.reason || b.stack))
        }), "insert" === a) {
            if (!e.length)
                throw new Error("insert requires an argument");
            if (e[0] = _.extend({}, e[0]), "_id" in e[0]) {
                if (c = e[0]._id, !("string" == typeof c || c instanceof Meteor.Collection.ObjectID))
                    throw new Error("Meteor requires document _id fields to be strings or ObjectIDs")
            } else
                c = e[0]._id = d._makeNewID()
        } else
            e[0] = Meteor.Collection._rewriteSelector(e[0]);
        if (d._connection && d._connection !== Meteor.default_server) {
            var f = Meteor._CurrentInvocation.get(), g = f && f.isSimulation;
            g || "insert" === a || throwIfSelectorIsNotId(e[0], a), b ? d._connection.apply(d._prefix + a, e, function(a) {
                b(a, !a && c)
            }) : d._connection.apply(d._prefix + a, e)
        } else {
            try {
                d._collection[a].apply(d._collection, e)
            } catch (h) {
                if (b)
                    return b(h), null;
                throw h
            }
            b && b(null, c)
        }
        return c
    }
}), Meteor.Collection.prototype._ensureIndex = function(a, b) {
    var c = this;
    if (!c._collection._ensureIndex)
        throw new Error("Can only call _ensureIndex on server collections");
    c._collection._ensureIndex(a, b)
}, Meteor.Collection.prototype._dropIndex = function(a) {
    var b = this;
    if (!b._collection._dropIndex)
        throw new Error("Can only call _dropIndex on server collections");
    b._collection._dropIndex(a)
}, Meteor.Collection.ObjectID = LocalCollection._ObjectID, function() {
    var a = function(a, b) {
        var c = ["insert", "update", "remove", "fetch", "transform"];
        _.each(_.keys(b), function(b) {
            if (!_.contains(c, b))
                throw new Error(a + ": Invalid key: " + b)
        });
        var d = this;
        if (d._restricted = !0, _.each(["insert", "update", "remove"], function(c) {
            if (b[c]) {
                if (!(b[c] instanceof Function))
                    throw new Error(a + ": Value for `" + c + "` must be a function");
                d._transform && (b[c].transform = d._transform), b.transform && (b[c].transform = Deps._makeNonreactive(b.transform)), d._validators[c][a].push(b[c])
            }
        }), b.update || b.remove || b.fetch) {
            if (b.fetch && !(b.fetch instanceof Array))
                throw new Error(a + ": Value for `fetch` must be an array");
            d._updateFetch(b.fetch)
        }
    };
    Meteor.Collection.prototype.allow = function(b) {
        a.call(this, "allow", b)
    }, Meteor.Collection.prototype.deny = function(b) {
        a.call(this, "deny", b)
    }
}(), Meteor.Collection.prototype._defineMutationMethods = function() {
    var a = this;
    if (a._restricted = !1, a._insecure = void 0, a._validators = {insert: {allow: [],deny: []},update: {allow: [],deny: []},remove: {allow: [],deny: []},fetch: [],fetchAllFields: !1}, a._name && (a._prefix = "/" + a._name + "/", a._connection)) {
        var b = {};
        _.each(["insert", "update", "remove"], function(c) {
            b[a._prefix + c] = function() {
                check(arguments, [Match.Any]);
                try {
                    if (this.isSimulation)
                        return a._collection[c].apply(a._collection, _.toArray(arguments)), void 0;
                    if ("insert" !== c && throwIfSelectorIsNotId(arguments[0], c), a._restricted) {
                        if (0 === a._validators[c].allow.length)
                            throw new Meteor.Error(403, "Access denied. No allow validators set on restricted collection for method '" + c + "'.");
                        var b = "_validated" + c.charAt(0).toUpperCase() + c.slice(1), d = [this.userId].concat(_.toArray(arguments));
                        a[b].apply(a, d)
                    } else {
                        if (!a._isInsecure())
                            throw new Meteor.Error(403, "Access denied");
                        a._collection[c].apply(a._collection, _.toArray(arguments))
                    }
                } catch (e) {
                    throw "MongoError" === e.name || "MinimongoError" === e.name ? new Meteor.Error(409, e.toString()) : e
                }
            }
        }), (Meteor.isClient || a._connection === Meteor.default_server) && a._connection.methods(b)
    }
}, Meteor.Collection.prototype._updateFetch = function(a) {
    var b = this;
    b._validators.fetchAllFields || (a ? b._validators.fetch = _.union(b._validators.fetch, a) : (b._validators.fetchAllFields = !0, b._validators.fetch = null))
}, Meteor.Collection.prototype._isInsecure = function() {
    var a = this;
    return void 0 === a._insecure ? Meteor.Collection.insecure : a._insecure
};
var docToValidate = function(a, b) {
    var c = b;
    return a.transform && (c = a.transform(EJSON.clone(b))), c
};
Meteor.Collection.prototype._validatedInsert = function(a, b) {
    var c = this;
    if (_.any(c._validators.insert.deny, function(c) {
        return c(a, docToValidate(c, b))
    }))
        throw new Meteor.Error(403, "Access denied");
    if (_.all(c._validators.insert.allow, function(c) {
        return !c(a, docToValidate(c, b))
    }))
        throw new Meteor.Error(403, "Access denied");
    c._collection.insert.call(c._collection, b)
};
var transformDoc = function(a, b) {
    return a.transform ? a.transform(b) : b
};
Meteor.Collection.prototype._validatedUpdate = function(a, b, c, d) {
    var e = this;
    if (!LocalCollection._selectorIsIdPerhapsAsObject(b))
        throw new Error("validated update should be of a single ID");
    var f = [];
    _.each(c, function(a, b) {
        if ("$" !== b.charAt(0))
            throw new Meteor.Error(403, "Access denied. In a restricted collection you can only update documents, not replace them. Use a Mongo update operator, such as '$set'.");
        if (!_.has(ALLOWED_UPDATE_OPERATIONS, b))
            throw new Meteor.Error(403, "Access denied. Operator " + b + " not allowed in a restricted collection.");
        _.each(_.keys(a), function(a) {
            -1 !== a.indexOf(".") && (a = a.substring(0, a.indexOf("."))), _.contains(f, a) || f.push(a)
        })
    });
    var g = {transform: null};
    e._validators.fetchAllFields || (g.fields = {}, _.each(e._validators.fetch, function(a) {
        g.fields[a] = 1
    }));
    var h = e._collection.findOne(b, g);
    if (h) {
        var i;
        if (_.any(e._validators.update.deny, function(b) {
            return i || (i = transformDoc(b, h)), b(a, i, f, c)
        }))
            throw new Meteor.Error(403, "Access denied");
        if (_.all(e._validators.update.allow, function(b) {
            return i || (i = transformDoc(b, h)), !b(a, i, f, c)
        }))
            throw new Meteor.Error(403, "Access denied");
        e._collection.update.call(e._collection, b, c, d)
    }
};
var ALLOWED_UPDATE_OPERATIONS = {$inc: 1,$set: 1,$unset: 1,$addToSet: 1,$pop: 1,$pullAll: 1,$pull: 1,$pushAll: 1,$push: 1,$bit: 1};
Meteor.Collection.prototype._validatedRemove = function(a, b) {
    var c = this, d = {transform: null};
    c._validators.fetchAllFields || (d.fields = {}, _.each(c._validators.fetch, function(a) {
        d.fields[a] = 1
    }));
    var e = c._collection.findOne(b, d);
    if (e) {
        if (_.any(c._validators.remove.deny, function(b) {
            return b(a, transformDoc(b, e))
        }))
            throw new Meteor.Error(403, "Access denied");
        if (_.all(c._validators.remove.allow, function(b) {
            return !b(a, transformDoc(b, e))
        }))
            throw new Meteor.Error(403, "Access denied");
        c._collection.remove.call(c._collection, b)
    }
};
var queue = [], loaded = "loaded" === document.readyState || "complete" == document.readyState, ready = function() {
    for (loaded = !0; queue.length; )
        queue.shift()()
};
document.addEventListener ? (document.addEventListener("DOMContentLoaded", ready, !1), window.addEventListener("load", ready, !1)) : (document.attachEvent("onreadystatechange", function() {
    "complete" === document.readyState && ready()
}), window.attachEvent("load", ready)), Meteor.startup = function(a) {
    var b = !document.addEventListener && document.documentElement.doScroll;
    if (b && window === top) {
        try {
            b("left")
        } catch (c) {
            return setTimeout(function() {
                Meteor.startup(a)
            }, 50), void 0
        }
        a()
    } else
        loaded ? a() : queue.push(a)
};
