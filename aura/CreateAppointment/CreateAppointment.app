<aura:application extends="force:slds">
    
    <aura:attribute name="leadId" type="String" />
    <aura:attribute name="leadOwnerId" type="String" />
    <aura:attribute name="leadRecord" type="Lead" />
    
    <lightning:layout ><lightning:layoutItem size="8">
        <lightning:recordViewForm recordId="{! v.leadId }" objectApiName="Lead" class="">
        	<lightning:card title="Customer Information">
                <div class="slds-grid slds-wrap slds-p-around_medium">
                    <lightning:outputField fieldName="FirstName" class="slds-col slds-size_1-of-2 " />
                    <lightning:outputField fieldName="LastName" class="slds-col slds-size_1-of-2"/>
                    <lightning:outputField fieldName="Street" class="slds-col slds-size_1-of-1" />
                    <lightning:outputField fieldName="City" class="slds-col slds-size_1-of-3" />
                    <lightning:outputField fieldName="State" class="slds-col slds-size_1-of-3" />
                    <lightning:outputField fieldName="PostalCode" class="slds-col slds-size_1-of-3" />
                </div>
        	</lightning:card>
        </lightning:recordViewForm>
        
        <lightning:recordViewForm recordId="{! v.leadOwnerId }" objectApiName="User">
        	<lightning:card title="Lead Owner">
                <div class="slds-grid slds-wrap slds-p-around_medium">
                    <lightning:outputField fieldName="FirstName" class="slds-col slds-size_1-of-2 " />
                    <lightning:outputField fieldName="LastName" class="slds-col slds-size_1-of-2"/>
                    <lightning:outputField fieldName="Phone" class="slds-col slds-size_1-of-2" />
                    <lightning:outputField fieldName="Email" class="slds-col slds-size_1-of-2" />
                </div>
        	</lightning:card>
        </lightning:recordViewForm>
        
        <c:estimatorCalendar leadOwnerId="{! v.leadOwnerId }" leadId="{! v.leadId }"/>
    </lightning:layoutItem></lightning:layout>
</aura:application>