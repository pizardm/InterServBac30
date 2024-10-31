({
	doInit : function(component, event, helper) {
		console.log('Render Init');
		var recordId=component.get('v.recordId');
		var action = component.get('c.getQuoteLines');
		var MsgMargenesNegativos = $A.get("$Label.c.MsgMargenesNegativos");
		component.set('v.MsgMargenesNegativos', MsgMargenesNegativos);
		action.setParams({
			recordId : recordId
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS") {
				var flag = response.getReturnValue().flag;
				console.log(flag);
				if(flag == true){
					component.set('v.showbutton', true);
					console.log(response.getReturnValue().lstQuoteLine);
					component.set('v.data',response.getReturnValue().lstQuoteLine);
					helper.getColumn(component);
				}else if(flag == false){
					component.set('v.showbutton', false);
				}
			}
		});
		$A.enqueueAction(action);
	},
	showWindow:function(component, event, helper){
		component.set('v.showModal', true);
	},
	closeFileModal:function(component, event, helper){
		component.set('v.showModal', false);
	}
})