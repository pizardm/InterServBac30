/**
 * @description       :
 * @author            : emeza@freewayconsulting.com
 * @group             :
 * @last modified on  : 2024-08-14
 * @last modified by  : Rodrigo Olivera - rolivera@ts4.mx / Juan Pedraza - jpedraza@ts4.mx
 **/

import { LightningElement, api, wire, track } from "lwc";
import getRecord from "@salesforce/apex/individualApproverController.getRecord";
import sendForApproval from "@salesforce/apex/individualApproverController.approveRequest";
import fetchQuoteLineItems from "@salesforce/apex/individualApproverController.fetchQuoteLineItems";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import QUOTE_FIELD from "@salesforce/schema/Grupo_de_productos_a_aprobar__c.Cotizacion__c";
import LEVEL_FIELD from "@salesforce/schema/Grupo_de_productos_a_aprobar__c.Nivel__c";
import getRecordId from "@salesforce/apex/individualApproverController.getRecordId";

const FIELDS = [QUOTE_FIELD, LEVEL_FIELD];
const COLUMNS_NO = [
  { label: "Producto", fieldName: "SBQQ__ProductCode__c", initialWidth: 205 },
  { label: "Cantidad", fieldName: "SBQQ__Quantity__c", type: "number", initialWidth: 100, typeAttributes: { step: "0.01" }},
  { label: "Metros", fieldName: "METROS__c", type: "number", typeAttributes: { step: "0.01" }, initialWidth: 110 },
  { label: "Precio", fieldName: "SBQQ__OriginalPrice__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110},
  { label: "Descuento", fieldName: "SBQQ__Discount__c", type: "percent", typeAttributes: { step: "0.01" }, initialWidth: 110},
  { label: "Precio con descuento", fieldName: "PRECIO_DESCUENTO__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 115},
  { label: "Importe Bruto", fieldName: "IMPORTE_BRUTO__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 115},
  { label: "Margen Porcentaje", fieldName: "MARGEN_CONSOLIDADO_PORC__c", type: "percent",typeAttributes: { step: "0.01" }, initialWidth: 114},
  { label: "Margen Operación", fieldName: "MARGEN_CONSOLIDADO__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" },initialWidth: 115},
  { label: "Utilidad Consolidada", fieldName: "UTILIDAD_CONSOLIDADA__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110},
  { fieldName: "", label: "", initialWidth: 34, cellAttributes: { iconName: { fieldName: "dynamicIcon" } }, initialWidth: 110}
];
const COLUMNS_MB = [
  { label: "Código de producto", fieldName: "SBQQ__ProductCode__c",  initialWidth: 119 },
  { label: "Nombre de producto", fieldName: "INT_Nombre_de_producto__c", initialWidth: 205, wrapText: true },
  { label: "Precio base", fieldName: "PRECIO_BASE__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110 },
  { label: "Precio especial", fieldName: "SBQQ__ListPrice__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110 },
  { label: "Descuento", fieldName: "DESCTO_PROY_PORC__c", type: "percent", typeAttributes: {step: "0.00001", minimumFractionDigits: "2", maximumFractionDigits: "3"},initialWidth: 110 },
  { label: "Precio proyecto",fieldName: "PRECIO_PROY_SIN_IVA__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110},
  { label: "Importe bruto",fieldName: "TOTAL_PROYECTO__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110 },
  { label: "Margen porcentaje", fieldName: "MARGEN_PORC__c", type: "percent", typeAttributes: { step: "0.01" }, initialWidth: 110},
  { label: "Margen operación", fieldName: "MARGEN__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110 },
  { label: "Utilidad consolidada", fieldName: "UTILIDAD_CONSOLIDADA__c", type: "currency", typeAttributes: { currencyCode: "MXN", step: "0.01" }, initialWidth: 110 },
  { fieldName: "", label: "", initialWidth: 34, cellAttributes: { iconName: { fieldName: "dynamicIcon" } }, initialWidth: 110 }
];

export default class individualApprover2 extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api quote;
  @track quoteId;
  @track level;
  @api aprobadorAsignado;
  @api aprobadoresAsignado = [];
  @track isLoading = false;
  @track recordIdp = "" + this.recordId;
  comments = "";
  emptyPendingApproval = false;
  isEmptyQLINO = false;
  isEmptyQLIMB = false;
  selectedQLINO = [];
  selectedQLIMB = [];
  quoteLineItemsMB = [];
  quoteLineItemsNO = [];
  error;
  approvalLevel;
  columnsNO = COLUMNS_NO;
  columnsMB = COLUMNS_MB;
  users;
  @track isApproveButtonDisabled = true; // Estado del botón

  // Filas seleccionadas en la primera tabla
  selectedRowsNO = [];

  // Filas seleccionadas en la segunda tabla
  selectedRowsMB = [];
  
  connectedCallback() {
    this.recordIdp = this.recordId+"";
  }
  // Llamada a Apex usando @wire
  @wire(getRecordId, { groupId: "$recordIdp" })
  wiredValue({ error, data }) {
      if (data) {
        console.log("El valor de "+this.recordIdp);
          this.recordIdp = data;
      } else if (error) {
        console.log("El valor de "+this.recordIdp);
          console.error('Error: ', error);
      }
  }
  

  @wire(getRecord, { recordId: "$recordIdp" })
  wiredRecord({ error, data }) {
    if (error) {
      let message = "Unknown error";
      console.log("ERROR: " + JSON.stringify(error));
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        /*new ShowToastEvent({
          title: "Error loading Attachments",
          message: message,
          variant: "error"
        })*/
      );
    } else if (data) {
      console.log("SUCCESS:ENTRAMOS AQUI OTRA VEZ...");
      console.log(data);
      this.quoteId = data.quoteId;
      this.level = data.level;
      console.log(this.quoteId);
    }
  }

  @wire(fetchQuoteLineItems, { quoteId: "$quoteId", groupId: "$recordIdp" })
  wiredResult({ data, error }) {
    if (data) {
      let dataSize = [];
      dataSize = data;
      console.log("DATASize: " + dataSize);
      console.log("DATASize:LENGTH: " + dataSize.length);

      if (dataSize.length > 0) {
        console.log("ENTRAMOS AQUI");
        console.log("emptyPendingApproval", this.quoteLineItemsMB);
        console.log("approvalLevel", this.quoteLineItemsNO);
        if (
          this.quoteLineItemsMB.length === 0 &&
          this.quoteLineItemsNO.length === 0
        ) {
          data.forEach((element) => {
            console.log(
              "TIPO DE PRICEBOOK: " +
                element.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c
            );
            //Distincion por lista de precio
            if (element.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c) {
              this.quoteLineItemsMB = [...this.quoteLineItemsMB, element];
            } else {
              this.quoteLineItemsNO = [...this.quoteLineItemsNO, element];
            }
          });
        }

        this.isEmptyQLIMB = Object.keys(this.quoteLineItemsMB).length !== 0;
        this.isEmptyQLINO = Object.keys(this.quoteLineItemsNO).length !== 0;
        console.log(this.quoteLineItemsMB);
        console.log(this.quoteLineItemsNO);
      }
    } else if (error) {
      console.log(error);
      this.quoteLineItemsMB = [];
      this.quoteLineItemsNO = [];
    }
  }

handleClickApproveProcess() {
  sendForApproval({ groupId: this.recordIdp, comments: this.comments, isApproval: true })
    .then(() => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Éxito",
          message: "El registro ha sido enviado para aprobación con éxito.",
          variant: "success"
      })
      );
      // Esperar 2 segundos (2000 milisegundos) antes de refrescar la página
      setTimeout(() => {
        // Recargar la página actual
         const recordUrl = `/lightning/r/Grupo_de_productos_a_aprobar__c/${this.recordIdp}/view`;
        
        // Redirigir a la URL del registro
        window.location.href = recordUrl;
      }, 3000);
    })
    .catch((error) => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "No se pudo enviar la solicitud para aprobación. Detalle del error: " + error.body.message,
          variant: "error"
      })
      );
    });
}

handleClickRejectProcess() {
  sendForApproval({ groupId: this.recordIdp, comments: this.comments, isApproval: false })
    .then(() => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Éxito",
          message: "El registro ha sido enviado para rechazar con éxito.",
          variant: "success"
      })
      );
      setTimeout(() => {
        // Recargar la página actual
         const recordUrl = `/lightning/r/Grupo_de_productos_a_aprobar__c/${this.recordIdp}/view`;
        
        // Redirigir a la URL del registro
        window.location.href = recordUrl;
      }, 3000);
    })
    .catch((error) => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "No se pudo enviar la solicitud para rechazar. Detalle del error: " + error.body.message,
          variant: "error"
      })
      );
    });
  }

  get selectedValues() {
    return this.value.join(",");
  }

  getSelectedNameMB(event) {
    console.log("getSelectedNameMB");
    this.selectedRowsMB = event.detail.selectedRows;
    const selectedRows = event.detail.selectedRows;
    const selected = [];
    this.updateButtonState();
    // Display that fieldName of the selected rows
    selectedRows.forEach((element) => {
      selected.push(element);
    });
    this.selectedQLIMB = selected;

  }
  getSelectedNameNO(event) {
    this.selectedRowsNO = event.detail.selectedRows;
    console.log("getSelectedNameNO");
    const selectedRows = event.detail.selectedRows;
    const selected = [];
    this.updateButtonState();
    console.log(selectedRows);
    // Display that fieldName of the selected rows
    selectedRows.forEach((element) => {
      selected.push(element);
    });
    this.selectedQLINO = selected;
    console.log(selected);

  }
  // Actualiza el estado del botón basándose en las filas seleccionadas en ambas tablas
  updateButtonState() {
    // Verifica si las listas de filas no están vacías
    const isDataTableNOEmpty = this.quoteLineItemsNO.length === 0;
    const isDataTableMBEmpty = this.quoteLineItemsMB.length === 0;
    console.log("Tabla NO está vacía:", isDataTableNOEmpty);
    console.log("Tabla MB está vacía:", isDataTableMBEmpty);

    // Verifica si el número de filas seleccionadas en cada tabla es igual al número total de filas en la tabla, solo si las tablas no están vacías
    const allRowsSelectedNO =
      !isDataTableNOEmpty &&
      this.selectedRowsNO.length === this.quoteLineItemsNO.length;
    const allRowsSelectedMB =
      !isDataTableMBEmpty &&
      this.selectedRowsMB.length === this.quoteLineItemsMB.length;
    console.log(
      "Todas las filas seleccionadas en la tabla NO:",
      allRowsSelectedNO
    );
    console.log(
      "Todas las filas seleccionadas en la tabla MB:",
      allRowsSelectedMB
    );

    // El botón se habilita solo si todas las filas están seleccionadas en ambas tablas y las tablas no están vacías
    this.isApproveButtonDisabled = !(allRowsSelectedNO || allRowsSelectedMB);
    console.log(
      "Botón de aprobación está deshabilitado:",
      this.isApproveButtonDisabled
    );
  }
  callRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    if (actionName === "Edit") {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: recId,
          objectApiName: "Account",
          actionName: "edit"
        }
      });
    } else if (actionName === "View") {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: recId,
          objectApiName: "Account",
          actionName: "view"
        }
      });
    }
  }
  handleRowAction(event) {
    // Obtén las filas seleccionadas
    const selectedRows = event.detail.selectedRows;
    this.updateButtonState();

    // Verifica si todas las filas están seleccionadas
    this.checkIfAllRowsSelected(selectedRows);
    if (event.detail.action.name === "viewApprovals") {
      console.log(" Aprobadores");
    }
  }

  // Verifica si todas las filas están seleccionadas
  checkIfAllRowsSelected(selectedRows) {
    // Obtén el número total de filas y el número de filas seleccionadas
    const totalRows = this.quoteLineItemsMB.length;
    const selectedCount = selectedRows.length;

    // Si el número de filas seleccionadas es igual al total, habilita el botón
    this.isApproveButtonDisabled = selectedCount !== totalRows;
  }

  get noProductsToApprove() {
    return (
      this.quoteLineItemsNO.length === 0 && this.quoteLineItemsMB.length === 0
    );
  }
  changeComments(event) {
    this.comments = event.target.value;
  }
}