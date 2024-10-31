({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Código del producto', fieldName: 'productCode', type: 'text'}
        ]);
        helper.getProducts(component,event);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    }
})