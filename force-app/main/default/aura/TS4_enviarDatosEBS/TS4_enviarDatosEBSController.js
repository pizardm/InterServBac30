({
    doInit: function(component, event, helper) {
        helper.apexCall(component, "c.productosEnvio", {
            caseOrProductId: component.get("v.recordId"),
            tipoObject: component.get("v.sObjectName")
        })
        .then((result) => {
            helper.uploadData(component);
        })
        .catch((errors) => {
             if (errors && errors[0] && errors[0].message) {
                helper.showToast('Error', errors[0].message, 'error', 'sticky');
            } else {
                helper.showToast('Error', 'Unknown error', 'error', 'sticky');
            }
        });
    },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    closeErrorModal : function(component, event, helper) {
        component.set("v.showErrorModal", false);
    }
})