(function (global) {
    var DemoViewModel,
        app = global.app = global.app || {};

    DemoViewModel = kendo.data.ObservableObject.extend({

        setup: function () {
            if (!this.checkSimulator()) {
                Dropbox.linkedAccounts(function(result){
                       Dropbox.linkAccount();
                });
            }
        },

        save: function (path) {
            if (!this.checkSimulator()) {
                var content = {
                    files : [path],
                    folder: "Saves"
                };
                Dropbox.save(
                    content,
                    function (msg) {alert("SUCCESS: " + JSON.stringify(msg))},
                    function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
                );
            }
        },

        capture :function(){
          var _this = this;
          navigator.camera.getPicture(function(result){
              _this.save(result);
          }, function(error){

          },{
            destinationType: Camera.DestinationType.FILE_URI
          });
        },

        checkSimulator: function() {
            if (window.navigator.simulator === true) {
                alert('This plugin is not available in the simulator.');
                return true;
            } else if (window.Dropbox  === undefined) {
                alert('Plugin not found. Maybe you are running in AppBuilder Companion app which currently does not support this plugin.');
                return true;
            } else {
                return false;
            }
        }
    });

    app.demoService = {
        viewModel: new DemoViewModel()
    };
})(window);
