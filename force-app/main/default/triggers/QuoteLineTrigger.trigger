trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<SBQQ__QuoteLine__c> quoteLines = Trigger.new;
            IQuoteLineUpdater updater = QuoteLineUpdaterFactory.getUpdater();
            updater.updateQuoteLines(quoteLines);
        }
    }
}