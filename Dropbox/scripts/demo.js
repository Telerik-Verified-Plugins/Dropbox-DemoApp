(function (global) {
    var DemoViewModel,
        app = global.app = global.app || {};

    DemoViewModel = kendo.data.ObservableObject.extend({

        setup: function () {
            if (!this.checkSimulator()) {
                dropbox.linkedAccounts(function(accounts) {
                    if (accounts.length == 0) {
                      dropbox.linkAccount(
                          function(result) {
                              alert("Linked? " + result.success);
                          });
                    } else {
                      navigator.notification.alert(
                            JSON.stringify(accounts),
                                  null,
                                  "Linked account(s)",
                                  "OK, that's nice"
                            );
                      }
                });
            }
        },

        save: function (path) {
            if (!this.checkSimulator()) {
                var content = {
                    files : [path],
                    folder: "Saves"
                };
                dropbox.save(
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
            destinationType: Camera.DestinationType.FILE_URI,
            quality: 50,
            targetWidth: 200,
            targetHeight: 200
          });
        },

        checkSimulator: function() {
            if (window.navigator.simulator === true) {
                alert('This plugin is not available in the simulator.');
                return true;
            } else if (window.dropbox === undefined) {
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
