({
    onLogout : function(component, event, helper) {
        console.log("Logout success.");
        var reason = event.getParam('reason');
        console.log(reason);

        // Espera 5 segundos (5000 ms) antes de intentar reconectar
        setTimeout(function() {
            var omniAPI = component.find("omniToolkit");
            omniAPI.loginAgent().then(function(result) {
                console.log('Reconnected to Omni-Channel successfully');
            }).catch(function(error) {
                console.log('Error reconnecting to Omni-Channel: ' + error);
            });
        }, 5000);  // 5 segundos de espera
    }
})