/******************************************************************* 
Name: TS4_consultCasesRest
Copyright © 2024 Salesforce
======================================================
Purpose:
Gets a List of cases in Salesforce using the REST API.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   15/08/2024
******************************************************************/
@RestResource(urlMapping='/cases')
global with sharing class TS4_consultCasesRest {
    private static final Integer MAX_RECORDS = 25000;

    // Clase envolvente para serialización personalizada
    public class CaseWrapper {
        public CaseDetails caseRecord;
        public String UsuSinter;

        public CaseWrapper(Case c) {
            this.caseRecord = new CaseDetails(c);
            this.UsuSinter = c.Contact.TS4_Cost_UsuSinter__c;
        }
    }

    // Clase interna para los detalles del caso
    public class CaseDetails {
        public String CaseNumber;
        public Datetime CreatedDate;
        public String Subject;
        public String Status;
        public String email;
        public String nombre;
        public String zona;
        public Id ContactId;
        public Id Id;

        public CaseDetails(Case c) {
            this.CaseNumber = c.CaseNumber;
            this.email = !String.isBlank(c.Contact.Email) ? c.Contact.Email:'';
            this.nombre = c.Contact.Name;
            this.CreatedDate = c.CreatedDate;
            this.Subject = c.Subject;
            this.Status = c.Status;
            this.zona = c.TS4_ZonaC__c;
            this.ContactId = c.ContactId;
            this.Id = c.Id;
        }
    }

    @HttpGet
    global static void getCases() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> response = new Map<String, Object>();
        
        // Parámetros de paginación obtenidos de los headers
        
        Map<String, String> requiredFields = new Map<String, String>{
            
            'pageSize' => req.headers.get('pageSize'),
            'pageNumber' => req.headers.get('pageNumber')
        };
        for (String fieldName : requiredFields.keySet()) {
            if (String.isBlank(requiredFields.get(fieldName))) {
                response.put('message', 'Error: El campo ' + fieldName + ' es obligatorio.');
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 400;
                return;
            }
        }
        System.debug('>>filtros');
        System.debug(req.headers.get('pageNumber'));
        Integer pageNumber = Integer.valueOf(req.headers.get('pageNumber'));
        Integer pageSize = Integer.valueOf(req.headers.get('pageSize'));
        List<String> filterIdSinter = (!String.isBlank(req.headers.get('idsSinter')))?req.headers.get('idsSinter').split(','):new List<String>();
        Date filterDateInit = String.isNotEmpty(req.headers.get('dateInit')) ? Date.valueOf(req.headers.get('dateInit')) : null;
        Date filterDateEnd = String.isNotEmpty(req.headers.get('dateEnd')) ? Date.valueOf(req.headers.get('dateEnd')).addDays(1) : null;
        String filterFranquicia = req.headers.get('clienteFranquicia');
        String filterNumeroCaso = req.headers.get('caseNumber');
        String filterStatus = req.headers.get('status');
        String filterCategoria = req.headers.get('category');
        
        List<String> filters = new List<String>();
        if(filterDateInit != null && filterDateEnd != null) filters.add('createdDate >=:filterDateInit AND createdDate <=:filterDateEnd');
        if(!String.isBlank(filterFranquicia)) filters.add('contact.email =:filterFranquicia');
        if(filterIdSinter != null && !filterIdSinter.isEmpty()) filters.add('Contact.TS4_Cost_UsuSinter__c in :filterIdSinter');
        if(!String.isBlank(filterNumeroCaso)) filters.add('caseNumber =:filterNumeroCaso');
        if(!String.isBlank(filterStatus)) filters.add('status =:filterStatus');
        if(!String.isBlank(filterCategoria)) filters.add('TS4_Categoria__c =:filterCategoria');
        
        String queryBase = 'SELECT Id FROM Case';
        if (!filters.isEmpty()) {
            queryBase += ' WHERE ' + String.join(filters, ' AND ');
        }
        queryBase += ' ORDER BY CreatedDate DESC LIMIT :MAX_RECORDS';
        System.debug('>>queryBase');
        System.debug(queryBase);
        List<Id> allCaseIds = new List<Id>();
        for (Case c : Database.query(queryBase)) {
            allCaseIds.add(c.Id);
        }
        
        Integer totalRecords = allCaseIds.size();
        Integer totalPages = Math.ceil(Decimal.valueOf(totalRecords) / Decimal.valueOf(pageSize)).intValue();
        
        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, totalRecords);
        
        List<Id> pageIds = new List<Id>();
        for (Integer i = startIndex; i < endIndex; i++) {
            pageIds.add(allCaseIds[i]);
        }
        
        String finalQuery = 'SELECT Id,CaseNumber, CreatedDate, Subject, Status, ContactId, Contact.TS4_Cost_UsuSinter__c,TS4_Correo__c,Contact.Name,Contact.Email,TS4_ZonaC__c FROM Case WHERE Id IN :pageIds ORDER BY CaseNumber DESC';
        List<Case> lstCases = Database.query(finalQuery);
        
        if(!lstCases.isEmpty()) {
            List<CaseWrapper> wrappedCases = new List<CaseWrapper>();
            for(Case c : lstCases) {
                wrappedCases.add(new CaseWrapper(c));
            }
            response.put('cases', wrappedCases);
            response.put('totalRecords', totalRecords);
            response.put('pageSize', pageSize);
            response.put('pageNumber', pageNumber);
            response.put('totalPages', totalPages);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
        } else {
            response.put('message', 'La información ingresada no es correcta, favor de verificar');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 404;
        }
    }
}