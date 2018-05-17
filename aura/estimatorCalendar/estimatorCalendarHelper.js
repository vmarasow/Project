({
	refreshEvents : function(component, start, end, cb) {
		var action = component.get('c.getEvents');
        action.setParams({"userId" : component.get("v.leadOwnerId"), "startTime" : start.toISOString(), "endTime" : end.toISOString()});
        
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var events = response.getReturnValue();
                cb($.map(events, function(element) {
                    return {
                        "start" : new Date(element.StartDateTime),
                        "end" : new Date(element.EndDateTime),
                        "subject" : element.Subject,
                        "salesforceId" : element.Id,
                        "location" : element.Location
                    };
                }));
            }
        }));
        
        $A.enqueueAction(action);
	}
})