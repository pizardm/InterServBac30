({
	getColumn : function(component) {
        component.set('v.columns', [
            {label: 'Nombre', fieldName: 'SBQQ__ProductName__c', type: 'text',cellAttributes: { alignment: 'left' },initialWidth: 840},
            {label: 'Código', fieldName: 'SBQQ__ProductCode__c', type: 'text',cellAttributes: { alignment: 'left' },initialWidth: 200},
            {label: 'Cantidad', fieldName: 'SBQQ__Quantity__c', type: 'text',cellAttributes: { alignment: 'center' },initialWidth: 145},
            {label: 'DESCTO PROY PORC', fieldName: 'DESCTO_PROY_PORC__c', type: 'text',cellAttributes: { alignment: 'center' },initialWidth: 200},
            {label: 'DESCTO FRANQ PORC', fieldName: 'DESCTO_FRANQ_PORC__c', type: 'text',cellAttributes: { alignment: 'center' },initialWidth: 200},
            ]);
    },

})