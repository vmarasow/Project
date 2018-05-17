({
	scriptsLoaded : function(component, event, helper) {
        $('#calendar').fullCalendar({
            events : $A.getCallback(function(start, end, timezone, cb) {
                helper.refreshEvents(component, start, end, $A.getCallback(cb));
            }),
            eventRender : $A.getCallback(function(event, elem) {
                elem.qtip({
                    content: {
                        title: event.subject,
                        text: 'Location: ' + event.location
                    },
                    position: {
                        'my': 'left center',
                        'at': 'right center'
                    }
                });
            }),
            dayClick : $A.getCallback(function(date, event, view) {
                component.set("v.newEvent", {
					"SobjectType": "Event",
                    "DurationInMinutes": 60,
                    "StartDateTime": new Date(date.format()).toLocaleTimeString('it-IT'),
                    "EndDateTime": new Date(date.add(1, 'hour').format()).toLocaleTimeString('it-IT'),
                    "ActivityDate": date.format('YYYY-MM-DD'),
                    "OwnerId": component.get("v.leadOwnerId"),
                    "ShowAs": "Busy",
                    "Subject": "Appointment"
                });
                component.set("v.showCreateEvent", true);
            }),
            defaultView : 'agendaWeek',
            minTime : '06:00:00',
            maxTime : '20:00:00'
        });
    },
    onInit : function(component, event, helper) {
        var action = component.get('c.getEventPicklistEntries');
        
        action.setParams({
            "fields" : ['ShowAs', 'Subject']
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                for (let field in result) {
                    var options = component.get("v.picklistOptions") || {};
                    options[field] = $.map(result[field], function(option) {
                        return { "value": option.value, "label": option.label};
                    });
                	component.set("v.picklistOptions", options);
                }
			}
        });
        $A.enqueueAction(action);
    },    
	closeModel : function(component, event, helper) {
		component.set("v.showCreateEvent", false);
	},
    saveEvent : function(component, event, helper) {
        var eventDate = component.get("v.newEvent.ActivityDate");
        
        var startTime = new Date(eventDate + ' ' + component.get("v.newEvent.StartDateTime"));
        var endTime = new Date(eventDate + ' ' + component.get("v.newEvent.EndDateTime"));
        
        if (startTime.getHours() < 6 || endTime.getHours() > 20) {
            alert("Appointments can only be scheduled between 6:00 AM and 8:00 PM. Please choose another time.");
            return;
        }
        
        var matchingBookings = $('#calendar').fullCalendar('clientEvents', function(event) {
            return ((startTime < event.end && startTime > event.start) || (endTime > event.start && endTime < event.end));
        });
        
        if (matchingBookings.length) {
            if (!confirm('You are submitting a double booking, continue?')) {
                return;
            }
        }
        component.set("v.newEvent.StartDateTime", startTime);
        component.set("v.newEvent.EndDateTime", endTime);
        
        var convertAction = component.get('c.convertLead');
        convertAction.setParams({
            "leadId" : component.get("v.leadId"),
            "newEventStr" : JSON.stringify(component.get("v.newEvent"))
        });
        convertAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                window.location = '/' + result.oppId
            } else if (response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors) {
                        console.log("Error message: " +
                                 errors[0].pageErrors[0].message);
                    } else {
                    	console.log("Unknown error");
                	}
                    component.set('v.showCreateEvent', false);
                }
            }
        });
        
        $A.enqueueAction(convertAction);
    }
})