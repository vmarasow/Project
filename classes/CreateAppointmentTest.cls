@isTest
public class CreateAppointmentTest {
	@TestSetup
    public static void createEvents() {
        Event ev1 = new Event(StartDateTime = System.now().addHours(1), EndDateTime = System.now().addHours(3), OwnerId = UserInfo.getUserId());
        Event ev2 = new Event(StartDateTime = System.now().addHours(10), EndDateTime = System.now().addHours(13), OwnerId = UserInfo.getUserId());
        
        insert new List<Event>{ev1, ev2};
    }
    
    @isTest
    public static void testGetEvents() {
        System.assert(CreateAppointmentController.getEvents(Id.valueOf(UserInfo.getUserId()), String.valueOf(System.now()), String.valueOf(System.now().addDays(1))).size() > 0);
    }
    
    @isTest
    public static void testGetPicklistEntries() {
        System.assert(CreateAppointmentController.getEventPicklistEntries(new List<String>{'Subject'}).get('Subject') != null);
    }
    
    @isTest
    public static void testConvertLeadAndInsertEvent() {
        Lead l = new Lead(FirstName='Zev', LastName='Marasow', Company='GSD Consulting', Email='velvel53@gmail.com', Street='123 Sesame St.');
        insert l;
        String eventStr = JSON.serialize(new Event(StartDateTime = System.now().addHours(1), EndDateTime = System.now().addHours(3), OwnerId = UserInfo.getUserId()));
        Map<String, String> result = CreateAppointmentController.convertLead(l.Id, eventStr);
        Contact createdContact = [SELECT FirstName FROM Contact WHERE Id = :result.get('cntId')];
        System.assert(createdContact.FirstName == l.FirstName);
        Event createdEvent = [SELECT Id FROM Event WHERE WhoId = :result.get('cntId') LIMIT 1];
        System.assert(createdEvent != null);
        
    }
}