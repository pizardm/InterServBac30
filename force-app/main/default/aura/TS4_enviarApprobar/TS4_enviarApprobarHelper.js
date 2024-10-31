({
    showNotification: function(component) {
        var title = component.get("v.notificationTitle");
        var message = component.get("v.notificationMessage");
        var variant = component.get("v.notificationType");

        var notification = $A.get("e.force:showToast");
        if (notification) {
            notification.setParams({
                title: title,
                message: message,
                type: variant
            });
            notification.fire();
        }
    }
})