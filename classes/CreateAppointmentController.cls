public class CreateAppointmentController {
	@AuraEnabled
    public static List<Event> getEvents(Id userId, String startTime, String endTime) {
        return [SELECT Id, Subject, Location, StartDateTime, EndDateTime FROM Event WHERE OwnerId = :userId AND StartDateTime >= :Date.valueOf(startTime) AND EndDateTime <= :Date.valueOf(endTime)];
    }
    
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getEventPicklistEntries(List<String> fields) {
        Map<String, List<Map<String, String>>> toReturn = new Map<String, List<Map<String, String>>>();
        
        Schema.DescribeSObjectResult sobjectDescribe = Event.getSobjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldDescribes = sobjectDescribe.fields.getMap();
        
        for (String field : fields) {
            List<Schema.PicklistEntry> picklistEntries = fieldDescribes.get(field).getDescribe().getPicklistValues();
            
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Schema.PicklistEntry entry : picklistEntries) {
                options.add(new Map<String, String>{'label' => entry.getLabel(), 'value' => entry.getValue()});
            }
            toReturn.put(field, options);
        }
                
        return toReturn;
    }
    
    @AuraEnabled
    public static Map<String, String> convertLead(String leadId, String newEventStr) {
        Map<String, String> toReturn = new Map<String, String>();
        Event newEvent = (Event) JSON.deserialize(newEventStr, Event.class);
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        toReturn.put('oppId', lcr.getOpportunityId());
        toReturn.put('cntId', lcr.getContactId());
        
        Lead leadRecord = [SELECT Id, Address FROM Lead WHERE Id = :leadId];
        
        newEvent.Location = leadRecord.Address.getStreet() + ', ' + leadRecord.Address.getCity() + ', ' + 
            leadRecord.Address.getState() + ', ' + leadRecord.Address.getPostalCode() + ', ' + leadRecord.Address.getCountry();
        newEvent.WhatId = lcr.getOpportunityId();
        newEvent.WhoId = lcr.getContactId();
        
        insert newEvent;
        
        return toReturn;
    }
}