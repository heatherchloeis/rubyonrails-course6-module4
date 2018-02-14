(function() {
  "use strict";

  angular
  	.module("spa-demo.subjects")
  	.factory("spa-demo.subjects.LinkableTagThing", LinkableTagThing);

  LinkableTagThing.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function LinkableTagThing($resource, APP_CONFIG) {
  	return $resource(APP_CONFIG.server_url + "/api/tags/:tag_id/linkable_tag_things");
  }
})();