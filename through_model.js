steal(
    './associative_model'
).then(function() {

    var classNames = {};

    var associativeModelSetup = can.Model.AssociativeModel.setup;
    can.Model.AssociativeModel.setup = function() {
        associativeModelSetup.apply(this, arguments);
        if (this == can.Model.AssociativeModel) return;

        classNames[this.shortName] = this;

        var self = this;
        can.forEachAssociation(this.associations, function(assocType, association) {
            if (association.through && assocType == "hasMany") {
                hasMany(self, association)
            }
        });
    };

    function hasMany(self, association) {
        var type = association.type;
        var name = association.name;
        var clazz;
        var throughName = association.through;
        var sourceName = association.source || can.singularize(name);
        var cap = can.classize(throughName);
        var oldSet = self.prototype[("set" + cap)];

        self.prototype[("set" + cap)] = function(list) {
            var self = this,
                nameSpace = throughName+"_through_"+this._cid,
                oldList = this[throughName];

            clazz = clazz || can.getObject(type);

            list = this[throughName] = oldSet.call(this, list);

            if (oldList != list) {
                if (oldList) removeThroughs(self, nameSpace, oldList);
                addThroughs(self, nameSpace, list);
                list.bind("add."+nameSpace, function(ev, throughs) {
                    addThroughs(self, nameSpace, throughs);
                });
                list.bind("remove."+nameSpace, function(ev, throughs) {
                    removeThroughs(self, nameSpace, throughs);
                });
            }

            return list;
        };

        return name;

        function addThroughs(self, nameSpace, throughs) {
            for (var i = 0; i < throughs.length; ++i) {
                (function(through) {
                    var oldSource = through[sourceName];
                    through.bind(sourceName+"." + nameSpace, function(ev, newSource) {
                        removeSource(self, nameSpace, through, oldSource);
                        addSource(self, nameSpace, through, newSource);
                        oldSource = newSource;
                    });
                })(throughs[i]);

                addSource(self, nameSpace, throughs[i], throughs[i][sourceName]);

            }
        }

        function removeThroughs(self, nameSpace, throughs) {
            for (var i = 0; i < throughs.length; ++i) {
                throughs[i].unbind(sourceName+"." + nameSpace);
                removeSource(self, nameSpace, throughs[i], throughs[i][sourceName]);
            }
        }

        function addSource(self, nameSpace, throughInstance, sourceInstance) {
            if (!sourceInstance) return;

            if (typeof sourceInstance._assocData["refs."+nameSpace] == "undefined") {
                sourceInstance._assocData["refs."+nameSpace] = {};
                if (!self[name]) self.attr(name, new can.Model.AssociativeList(this, clazz, name));
                self[name].push(clazz.model(sourceInstance));
            }
            sourceInstance._assocData["refs."+nameSpace][throughInstance._cid] = true;
        }

        function removeSource(self, nameSpace, throughInstance, sourceInstance) {
            if (!sourceInstance) return;

            if (sourceInstance._assocData["refs."+nameSpace] && sourceInstance._assocData["refs."+nameSpace][throughInstance._cid]) {
                delete sourceInstance._assocData["refs."+nameSpace][throughInstance._cid];
                for (var notEmpty in sourceInstance._assocData["refs."+nameSpace]) {break;}
                if (!notEmpty) {
                    delete sourceInstance._assocData["refs."+nameSpace];
                    self[name].remove(sourceInstance)
                }
            }
        }
    }
});