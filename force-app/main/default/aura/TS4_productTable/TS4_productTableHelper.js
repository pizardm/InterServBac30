({
    getProducts : function(component,event) {
        var action = component.get("c.getProductList");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length >0){
                    component.set('v.data',result);
                    component.set("v.maxPage", Math.ceil(result.length / 5));
                    component.set("v.isData", true);
                    this.renderPage(component);
                }else{
                    component.set("v.isData", false);
                }
            } else if (state === "ERROR") {
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast('Error',errors[0].message,'error','sticky');
                    }
                } else {
                    this.showToast('Error','Unknown error','error','sticky'); 
                }
			}
        });
        $A.enqueueAction(action);
    },
    renderPage: function(component) {
		var records = component.get("v.data"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*5, pageNumber*5);
        component.set("v.currentList", pageRecords);
	},
    showToast : function (title,message,type,mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    }
})