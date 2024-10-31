({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        // Call the Apex method to get the actors
        var action = component.get("c.getUsersApproval");
        action.setParams({ groupId: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Assign the actors to the component attribute
                component.set("v.actors", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                var errorMessage = "Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errorMessage = errors[0].message;
                }
                component.set("v.error", errorMessage);
            }
        });
        $A.enqueueAction(action);
    }
})