public class BSCDelegateCaptureController
{
    public Special_Event__c BSCEvent {get; set;}
    public List<Special_Event_Booking__c> BSCEventBookings {get; set;}
    public List<Temp_Special_Event_Booking__c> newBSCEventBookings {get; set;}
    
    public List<EventBookingRecs> EventBookingRecords {get; set;}

    public integer index {get; set;}
    public integer popupIndex {get; set;}
    public boolean isSubstitute {get; set;}
    public boolean isNotChanged {get; set;}
    public string url {get;set;}
    
    public Map<String, Contact> allContactMap {get;set;}
    public Map<String, Contact> currentContactMap {get;set;}
    public Map<String, Account> currentAccountMap {get;set;}
        
    public List<Contact> duplicateContacts {get;set;}
    
    public List<duplicateContacts> contactFound {get;set;}

    public List<substituteContacts> allSubstitutes{get; set;}

    public boolean displayPopup {get; set;}
    public boolean enableSave {get; set;}
    public boolean errorFlag {get; set;}
    
    public List<SelectOption> l_eventAccounts {get;set;}
    public Set<SelectOption> s_eventAccounts {get;set;}
    
    public String recType {get;set;}

    public class substituteContacts
    {
        public EventBookingRecs oldRecord {get; set;}
        public EventBookingRecs newRecord {get; set;}
    }

    //public Map<Temp_Special_Event_Booking__c, Boolean> newDelegates {get;set;}

    public class duplicateContacts
    {
        public integer index {get; set;}
        public boolean selectedContact {get; set;}
        public String contactStatus {get; set;}
        public Contact dupContact {get;set;}
    }
    
    public class EventBookingRecs
    {
        public integer index {get; set;}

        public Boolean isSubstitute {get; set;}
        public Boolean isShow {get;set;}
        public Boolean isCheckBoxShow {get;set;}
        public Boolean isEmail {get;set;}
        public Boolean deleteDelegate {get;set;}
        public Boolean isOdd {get;set;}
                
        public sObject EventBooking {get; set;}
        public string status {get;set;}
        
        public Id AccountId {get;set;}
        public Account bookingAccount {get;set;}
        public Id ContactId {get;set;}
        public Contact bookingContact {get;set;}
        
        public EventBookingRecs()
        {
            //system.debug('EventBookingRecs');
        }

        public EventBookingRecs(EventBookingRecs newRec)
        {
            system.debug('EventBookingRecs');
            this.index = newRec.index;

            this.isSubstitute = newRec.isSubstitute;
            this.isShow = newRec.isShow;
            this.isCheckBoxShow = newRec.isCheckBoxShow;
            this.isEmail = newRec.isEmail;
        
            this.EventBooking = newRec.EventBooking;
            //this.bookingAccount = new Account(id=newRec.bookingAccount.id, Name=newRec.bookingAccount.name);
            this.bookingAccount = new Account(Name=newRec.bookingAccount.name);
            this.bookingContact = new Contact(Email=newRec.bookingContact.email, title=newRec.bookingContact.title, FirstName=newRec.bookingContact.firstname, LastName=newRec.bookingContact.lastname, phone=newRec.bookingContact.phone, birthdate=newRec.bookingContact.birthdate);
        }
    }

    public BSCDelegateCaptureController(ApexPages.StandardController controller) 
    {
        BSCEvent = (Special_Event__c)controller.getRecord();
        BSCEvent = [SELECT Name, Owner.name, Recordtype.name, Product__r.name, Product__r.Require_DOB_on_DCForm__c, opportunity__c, startdate__c, enddate__c, Status__c FROM Special_Event__c where id = :BSCEvent.id];
        system.debug('Inside BSCDelegateCaptureController');

        BSCEventBookings = new List<Special_Event_Booking__c> ();
    
        BSCEventBookings = [SELECT Id, Name, Company__c, Company__r.name, Company__r.isPersonAccount, Contact__c, Contact__r.title
                                , Contact__r.firstname, Contact__r.lastname, Contact__r.email, Contact__r.phone, Contact__r.birthdate
                                , Special_Event__c, status__c, opportunity__c, opportunity__r.recordtype.name
                                , Partial_Attendance_Flag__c, Attendance_Notes__c
                                FROM Special_Event_Booking__c where special_event__c = :BSCEvent.id 
                                and opportunity__r.recordtype.name = :BSCEvent.recordtype.name
                                and Status__c in ('Confirmed', 'Attended', 'No Show') order by Company__r.name, Name];

        recType = '';
        if(BSCEventBookings.size() > 0)
        {
            recType = BSCEventBookings[0].Opportunity__r.Recordtype.name;
        }

        if(BSCEvent != null && BSCEventBookings.size() > 0)
        {
/*
            BSCEventBookings = new List<Special_Event_Booking__c> ();
    
            BSCEventBookings = [SELECT Id, Name, Company__c, Company__r.name, Company__r.isPersonAccount, Contact__c, Contact__r.title
                                , Contact__r.firstname, Contact__r.lastname, Contact__r.email, Contact__r.phone, Contact__r.birthdate
                                , Special_Event__c, status__c, opportunity__c, opportunity__r.recordtype.name
                                , Partial_Attendance_Flag__c, Attendance_Notes__c
                                FROM Special_Event_Booking__c where special_event__c = :BSCEvent.id 
                                and opportunity__r.recordtype.name = :BSCEvent.recordtype.name
                                and Status__c not in ('Confirmed', 'Attended', 'No Show') order by Company__r.name, Name];
*/
            system.debug('BSCEventBookings - ' + BSCEventBookings);

            newBSCEventBookings = new List<Temp_Special_Event_Booking__c> ();

            if(BSCEvent.recordtype.name == 'In-Company Event' && recType != '')
            {
                newBSCEventBookings = [SELECT Id, Name, Company__c, Company__r.name, Company__r.isPersonAccount, Contact__c, Contact__r.title
                                , Contact__r.firstname, Contact__r.lastname, Contact__r.email, Contact__r.phone, Contact__r.birthdate
                                , Special_Event__c, status__c, opportunity__c, opportunity__r.recordtype.name 
                                , Partial_Attendance_Flag__c, Attendance_Notes__c, isNew__c
                                FROM Temp_Special_Event_Booking__c where Special_Event__c = :BSCEvent.id order by Company__r.name, Name];
            }
            system.debug('BSCEventBookings - ' + BSCEventBookings);

            EventBookingRecords = new List<EventBookingRecs> ();

            allContactMap = new Map<String, Contact> ();
            currentContactMap = new Map<String, Contact> ();
            currentAccountMap = new Map<String, Account> ();
                        
            l_eventAccounts = new List<SelectOption> ();
            s_eventAccounts = new Set<SelectOption> ();

            integer counter = 0;
            
            for(Special_Event_Booking__c seb : BSCEventBookings)
            {
                EventBookingRecs ebrEven = new EventBookingRecs();
                ebrEven.EventBooking = (Special_Event_Booking__c) seb;
                ebrEven.status = seb.Status__c;
                ebrEven.bookingAccount = new Account(Id=null);
                ebrEven.bookingContact = new Contact(Id=null);
                if(seb.Company__c != null)
                {
                    //ebrEven.bookingAccount.id=seb.Company__c;
                    ebrEven.bookingAccount.Name=seb.Company__r.name;
                    ebrEven.bookingContact.AccountId=seb.Company__c;
                    ebrEven.AccountId = seb.Company__c;
                }

                if(seb.Contact__c != null)
                {
                    ebrEven.bookingContact.Email=seb.Contact__r.email;
                    ebrEven.bookingContact.title=seb.Contact__r.title;
                    ebrEven.bookingContact.FirstName=seb.Contact__r.firstname.capitalize();
                    ebrEven.bookingContact.LastName=seb.Contact__r.lastname.capitalize();
                    ebrEven.bookingContact.phone=seb.Contact__r.phone;
                    ebrEven.bookingContact.birthdate=seb.Contact__r.birthdate;
                    ebrEven.ContactId = seb.Contact__c;
                }
                ebrEven.isCheckBoxShow = true;
                ebrEven.isEmail = true;
                if(ebrEven.bookingContact.email != null)
                {
                    ebrEven.isEmail = false;
                }

                ebrEven.isShow = true;
                ebrEven.isSubstitute = false;
                ebrEven.isOdd = false;
                ebrEven.index = counter++;
                EventBookingRecords.add(ebrEven);

                EventBookingRecs ebrOdd = new EventBookingRecs();
                ebrOdd.EventBooking = (Special_Event_Booking__c) seb;
                ebrOdd.status = seb.Status__c;
                ebrOdd.bookingAccount = new Account(Id=null);
                ebrOdd.bookingContact = new Contact(Id=null);

                if(seb.Company__c != null)
                {
                    //ebrOdd.bookingAccount.id=seb.Company__c;
                    ebrOdd.bookingAccount.Name=seb.Company__r.name;
                    ebrOdd.bookingContact.AccountId=seb.Company__c;
                    ebrOdd.AccountId = seb.Company__c;
                }

                ebrOdd.isCheckBoxShow = false;
                ebrOdd.isEmail = true;
                ebrOdd.isShow = false;
                ebrOdd.isSubstitute = true;
                ebrOdd.isOdd = true;
                ebrOdd.index = counter++;
                EventBookingRecords.add(ebrOdd);

                s_eventAccounts.add(new SelectOption(seb.Company__c, seb.Company__r.name));
            }

            system.debug('EventBookingRecords 1 - ' + EventBookingRecords);

            for(Temp_Special_Event_Booking__c seb : newBSCEventBookings)
            {
                EventBookingRecs ebrNew = new EventBookingRecs();
                ebrNew.EventBooking = (Temp_Special_Event_Booking__c) seb;
                ebrNew.bookingAccount = new Account(id=null, Name=seb.Company__r.name);
                ebrNew.bookingContact = new Contact(Id=null, AccountId=seb.Company__c, Email=seb.Contact__r.email, title=seb.Contact__r.title, FirstName=seb.Contact__r.firstname, LastName=seb.Contact__r.lastname, phone=seb.Contact__r.phone, birthdate=seb.Contact__r.birthdate);
                ebrNew.ContactId = seb.Contact__c;
                ebrNew.AccountId = seb.Company__c;
                if(ebrNew.bookingContact.email != null)
                {
                    ebrNew.isCheckBoxShow = false;
                    ebrNew.isEmail = false;
                }
                else
                {
                    ebrNew.isCheckBoxShow = false;
                    ebrNew.isEmail = true;
                }

                ebrNew.isShow = true;
                ebrNew.isSubstitute = false;
                ebrNew.index = counter++;
                EventBookingRecords.add(ebrNew);
                s_eventAccounts.add(new SelectOption(seb.Company__c, seb.Company__r.name));
            }

            system.debug('EventBookingRecords 2 - ' + EventBookingRecords);
            l_eventAccounts = new List<SelectOption> (s_eventAccounts);
            l_eventAccounts.sort();
            system.debug('s_eventAccounts - ' + s_eventAccounts);
/*
            for(EventBookingRecs ebr : EventBookingRecords)
            {
                system.debug('ebr.AccountId - ' + ebr.AccountId);
                system.debug('ebr.EventBooking.name - ' + ebr.EventBooking.get('name'));
                system.debug('ebr.EventBooking.Status__c - ' + ebr.EventBooking.get('Status__c'));
                system.debug('ebr.status - ' + ebr.status);
                system.debug('ebr.EventBooking.get(Partial_Attendance_Flag__c) - ' + ebr.EventBooking.get('Partial_Attendance_Flag__c'));
            }
*/
        }

        displayPopup = false;
        enableSave = true;
        errorFlag = false;
        isNotChanged = true;
        index = 0;
        url = 'https://login.salesforce.com';
    }

    public PageReference searchContact()
    {
        system.debug('Inside searchContact');
        system.debug('index - ' + index);
        system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);
//        if(EventBookingRecords[index].bookingAccount.id == null)
        if(EventBookingRecords[index].AccountId == null)
        {
            system.debug('Inside if');
            system.debug('l_eventAccounts[0].getLabel() - ' + l_eventAccounts[0].getLabel());
            //EventBookingRecords[index].bookingAccount.id = l_eventAccounts[0].getValue();
            EventBookingRecords[index].AccountId = l_eventAccounts[0].getValue();
            EventBookingRecords[index].bookingAccount.name = l_eventAccounts[0].getLabel();
            EventBookingRecords[index].bookingContact.AccountId = l_eventAccounts[0].getValue();
            //system.debug('EventBookingRecords[index].bookingAccount.id - ' + EventBookingRecords[index].bookingAccount.id);
            system.debug('EventBookingRecords[index].AccountId - ' + EventBookingRecords[index].AccountId);
            system.debug('EventBookingRecords[index].bookingAccount.name - ' + EventBookingRecords[index].bookingAccount.name);
        }
        else
        {
            system.debug('Inside else');
            for(SelectOption s : l_eventAccounts)
            {
                //if(EventBookingRecords[index].bookingAccount.id == s.getValue())
                if(EventBookingRecords[index].AccountId == s.getValue())
                {
                    //EventBookingRecords[index].bookingContact.AccountId = EventBookingRecords[index].bookingAccount.id;
                    EventBookingRecords[index].bookingContact.AccountId = EventBookingRecords[index].AccountId;
                    EventBookingRecords[index].bookingAccount.name = s.getLabel();
                    //system.debug('EventBookingRecords[index].bookingAccount.id - ' + EventBookingRecords[index].bookingAccount.id);
                    system.debug('EventBookingRecords[index].AccountId - ' + EventBookingRecords[index].AccountId);
                    system.debug('EventBookingRecords[index].bookingAccount.name - ' + EventBookingRecords[index].bookingAccount.name);
                }
            }
        }

        List<Contact> allAccountContacts = [Select Id, Title, FirstName, LastName, Email, Phone, Birthdate, AccountId, account.name 
                                            From Contact where account.id = :EventBookingRecords[index].bookingContact.AccountId]; 
        system.debug('List<Contact> allAccountContacts - ' + allAccountContacts);
        
        for(Contact c : allAccountContacts)
        {
            allContactMap.put(c.email, c);
        }

        allContactMap.remove(null);
        system.debug('allContactMap - ' + allContactMap.values());

        integer cnt = 0;
        for(EventBookingRecs e : EventBookingRecords)
        {
            if(e.bookingContact.email != null)
            {
                if(cnt != index)
                {
                    currentContactMap.put(e.bookingContact.email, e.bookingContact);
                    currentAccountMap.put(e.bookingContact.email, e.bookingAccount);
                }
            }
            cnt++;
        }

        Contact all_c = new Contact();
        all_c = allContactMap.get(EventBookingRecords[index].bookingContact.email);
        system.debug('all_c - ' + all_c);

        Contact curr_c = new Contact();
        curr_c = currentContactMap.get(EventBookingRecords[index].bookingContact.email);
        system.debug('curr_c - ' + curr_c);

        if(curr_c != null)
        {
            system.debug('1');
            system.debug('EventBookingRecords[index] - ' + EventBookingRecords[index]);
            Account curr_a = new Account();
            curr_a = currentAccountMap.get(EventBookingRecords[index].bookingContact.email);
            //EventBookingRecords[index].bookingContact.email.adderror(EventBookingRecords[index].bookingContact.email + ' is already used by 1 ' + curr_c.firstname + ' ' + curr_c.lastname + ' ( ' + EventBookingRecords[index].bookingAccount.name + ' (' + EventBookingRecords[index].bookingAccount.id + '))');
            EventBookingRecords[index].bookingContact.email.adderror(EventBookingRecords[index].bookingContact.email + ' is already used by 1 ' + curr_c.firstname + ' ' + curr_c.lastname + ' ( ' + EventBookingRecords[index].bookingAccount.name + ' )');
            EventBookingRecords[index].bookingContact.email = '';
            return null;
        }
        else if(all_c != null)
        {
            Contact currContact = EventBookingRecords[index].bookingContact;
            system.debug('2');
            if(currContact.email == all_c.email && currContact.AccountId != all_c.AccountId)
            {
                system.debug('3');
                String accountName;
                for(SelectOption s : s_eventAccounts)
                {
                    if(all_c.AccountId == s.getValue())
                    {
                        accountName = s.getLabel();
                    }
                }
                //EventBookingRecords[index].bookingContact.email.adderror(all_c.email + ' is already used by ' + all_c.firstname + ' ' + all_c.lastname + ' ( ' + all_c.account.name + ' (' + all_c.AccountId + '))');
                EventBookingRecords[index].bookingContact.email.adderror(all_c.email + ' is already used by 2 ' + all_c.firstname + ' ' + all_c.lastname + ' ( ' + accountName + ' )');
                EventBookingRecords[index].bookingContact.email = '';
            }
            else
            {
                system.debug('4');
                system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);
                system.debug('EventBookingRecords[index].bookingContact.phone - ' + EventBookingRecords[index].bookingContact.phone);
                EventBookingRecords[index].ContactId = all_c.id;
                EventBookingRecords[index].AccountId = all_c.AccountId;

                EventBookingRecords[index].bookingContact.AccountId = all_c.AccountId;
                EventBookingRecords[index].bookingContact.email = all_c.email;

                if(all_c.title != null)
                {
                    system.debug('EventBookingRecords[index].bookingContact.title - ' + EventBookingRecords[index].bookingContact.title);
                    system.debug('all_c.title - ' + all_c.title);
                    EventBookingRecords[index].bookingContact.title = all_c.title;
                }
                if(all_c.firstname != null)
                {
                    EventBookingRecords[index].bookingContact.firstname = all_c.firstname;
                }
                if(all_c.lastname != null)
                {
                    EventBookingRecords[index].bookingContact.lastname = all_c.lastname;
                }
                if(all_c.phone != null)
                {
                    EventBookingRecords[index].bookingContact.phone = all_c.phone;
                }
                if(all_c.birthdate != null)
                {
                    EventBookingRecords[index].bookingContact.birthdate = all_c.birthdate;
                }
                EventBookingRecords[index].EventBooking.put('Status__c', EventBookingRecords[index].EventBooking.get('Status__c'));
                system.debug('EventBookingRecords[index].EventBooking.Status__c - ' + EventBookingRecords[index].EventBooking.get('Status__c'));
                system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);
            }
        }
        else
        {
            system.debug('EventBookingRecords[index].EventBooking.Status__c - ' + EventBookingRecords[index].EventBooking.get('Status__c'));
        }
        isNotChanged = false;
        return null;
    }

    public void substituteDelegate()
    {
        system.debug('index - ' + index);
        system.debug('isSubstitute - ' + isSubstitute);
        if(isSubstitute == false)
        {
            EventBookingRecords[index].isSubstitute = true;
            EventBookingRecords[index+1].isSubstitute = false;
            EventBookingRecords[index+1].isShow = true;
            EventBookingRecords[index+1].isCheckBoxShow = false;
        }
        if(isSubstitute == true)
        {
            EventBookingRecords[index].isSubstitute = false;
            EventBookingRecords[index+1].isSubstitute = true;
            EventBookingRecords[index+1].isShow = false;
            EventBookingRecords[index+1].isCheckBoxShow = false;
        }
        system.debug('EventBookingRecords[index].isSubstitute - ' + EventBookingRecords[index].isSubstitute);
        system.debug('EventBookingRecords[index+1].isSubstitute - ' + EventBookingRecords[index+1].isSubstitute);
    }
    
    public void addDelegates()
    {
        system.debug('Inside addDelegates');
        Boolean flag = false;
        system.debug('EventBookingRecords - ' + EventBookingRecords);

        for(EventBookingRecs er : EventBookingRecords)
        {
            if(er.EventBooking.get('name') != null && (er.bookingContact.firstname == null || er.bookingContact.lastname == null) && er.isShow == true)
            {
                system.debug('er.bookingContact.email - ' + er.bookingContact.email);
                system.debug('er.EventBooking.Name - ' + String.valueof(er.EventBooking.get('name')));
                if(er.bookingContact.firstname == null)
                {
                    er.bookingContact.firstname.adderror('Use Empty Booking before adding New Delegate');
                }
                if(er.bookingContact.lastname == null)
                {
                    er.bookingContact.lastname.adderror('Use Empty Booking before adding New Delegate');
                }
                flag = true;
                break;
            }
        }
        system.debug('flag 1 - ' + flag);
        if(flag == false)
        {
            EventBookingRecs newDelegate = new EventBookingRecs();
            newDelegate.AccountId = l_eventAccounts[0].getValue();
            newDelegate.bookingAccount = new Account(id=null);
            newDelegate.bookingContact = new Contact(id=null);
            newDelegate.EventBooking = new Temp_Special_Event_Booking__c(Special_Event__c=BSCEvent.id);
            newDelegate.isShow = true;
            newDelegate.isCheckBoxShow = false;
            newDelegate.isSubstitute = false;
            newDelegate.isEmail = true;
            newDelegate.index = EventBookingRecords.size();
            index = newDelegate.index;
            system.debug('newDelegate.accountid - ' + newDelegate.accountid);
            system.debug('newDelegate - ' + newDelegate);
            EventBookingRecords.add(newDelegate);
        }
        system.debug('addDelegates EventBookingRecords - ' + EventBookingRecords);
    }

    public void deleteDelegate()
    {
        system.debug('index - ' + index);

        if(EventBookingRecords[index].EventBooking.id != null)
        {
            delete (Temp_Special_Event_Booking__c)EventBookingRecords[index].EventBooking;
        }
        EventBookingRecords.remove(index);
        integer index = 0;
        for(EventBookingRecs er : EventBookingRecords)
        {
            er.index = index++;
        }
    }

    public void setSelectedId()
    {
        // Don't remove this function though it is empty, it sets the popup index
        system.debug('popupIndex - ' + popupIndex);
        //popupIndex = popupIndex;
        if(popupIndex >= 0)
        {
            enableSave = false;
        }
    }    

    public void savePopup()
    {
        system.debug('Inside savePopup()');
        system.debug('popupIndex - ' + popupIndex);

        if(popupIndex == null)
        {
            contactFound[0].dupContact.adderror('Please Select Contact');
        }
        else
        {
            system.debug('contactFound[id].dupContact - ' + contactFound[popupIndex].dupContact);
            system.debug('index - ' + popupIndex);
            system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);

            if(contactFound[popupIndex].contactStatus  == 'Exists & Not Used')
            {
                system.debug('Exists & Not Used');
                EventBookingRecords[index].bookingContact.Email=contactFound[popupIndex].dupContact.email;
                EventBookingRecords[index].bookingContact.title=contactFound[popupIndex].dupContact.title;
                EventBookingRecords[index].bookingContact.FirstName=contactFound[popupIndex].dupContact.firstname.capitalize();
                EventBookingRecords[index].bookingContact.LastName=contactFound[popupIndex].dupContact.lastname.capitalize();
                EventBookingRecords[index].bookingContact.phone=contactFound[popupIndex].dupContact.phone;
                EventBookingRecords[index].bookingContact.birthdate=contactFound[popupIndex].dupContact.birthdate;
                EventBookingRecords[index].ContactId = contactFound[popupIndex].dupContact.id;
            }
            system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);
            system.debug('EventBookingRecords[index] - ' + EventBookingRecords[index]);
            displayPopup = false;
            enableSave = true;
        }
    }

    public void saveValues() 
    {
        system.debug('saveValues');
        system.debug('index - ' + index);
        EventBookingRecords[index].bookingContact.AccountId = EventBookingRecords[index].AccountId;
        EventBookingRecords[index].bookingContact.email = EventBookingRecords[index].bookingContact.email;
        EventBookingRecords[index].bookingContact.title = EventBookingRecords[index].bookingContact.title;
        EventBookingRecords[index].bookingContact.firstname = EventBookingRecords[index].bookingContact.firstname;
        EventBookingRecords[index].bookingContact.lastname = EventBookingRecords[index].bookingContact.lastname;
        EventBookingRecords[index].bookingContact.phone = EventBookingRecords[index].bookingContact.phone;
        EventBookingRecords[index].EventBooking.put('Status__c', EventBookingRecords[index].EventBooking.get('Status__c'));
        EventBookingRecords[index].bookingContact.birthdate = EventBookingRecords[index].bookingContact.birthdate;
        EventBookingRecords[index].EventBooking.put('Partial_Attendance_Flag__c', EventBookingRecords[index].EventBooking.get('Partial_Attendance_Flag__c'));
        if(EventBookingRecords[index].EventBooking.get('Partial_Attendance_Flag__c') == true)
        {
            EventBookingRecords[index].EventBooking.put('Attendance_Notes__c', EventBookingRecords[index].EventBooking.get('Attendance_Notes__c'));
        }
        else
        {
            EventBookingRecords[index].EventBooking.put('Attendance_Notes__c', '');
        }
        isNotChanged = false;
        system.debug('EventBookingRecords[index].bookingContact - ' + EventBookingRecords[index].bookingContact);
    }

    public void cancelPopup() 
    {
        system.debug('cancelPopup');
/*
        EventBookingRecords[index].bookingContact.firstname = '';
        EventBookingRecords[index].bookingContact.lastname = '';
        EventBookingRecords[index].bookingContact.email = '';
        EventBookingRecords[index].bookingContact.title = '';
        EventBookingRecords[index].bookingContact.phone = '';
        EventBookingRecords[index].bookingContact.birthdate = null;
*/
        displayPopup = false;
    }

    public void searchDuplicateName()
    {
        system.debug('searchDuplicateName');
        system.debug('index - ' + index);
        system.debug('EventBookingRecords[index].ContactId - ' + EventBookingRecords[index].ContactId);
        system.debug('EventBookingRecords[index].bookingContact.firstname - ' + EventBookingRecords[index].bookingContact.firstname);
        system.debug('EventBookingRecords[index].bookingContact.lastname - ' + EventBookingRecords[index].bookingContact.lastname);

        for(SelectOption s : s_eventAccounts)
        {
            //if(EventBookingRecords[index].bookingAccount.id == s.getValue())
            if(EventBookingRecords[index].AccountId == s.getValue())
            {
                //EventBookingRecords[index].bookingContact.AccountId = EventBookingRecords[index].bookingAccount.id;
                EventBookingRecords[index].bookingContact.AccountId = EventBookingRecords[index].AccountId;
                EventBookingRecords[index].bookingAccount.name = s.getLabel();
            }
        }

        //system.debug('EventBookingRecords[index].bookingAccount.id - ' + EventBookingRecords[index].bookingAccount.id);
        system.debug('EventBookingRecords[index].AccountId - ' + EventBookingRecords[index].AccountId);
        system.debug('EventBookingRecords[index].bookingAccount.Name - ' + EventBookingRecords[index].bookingAccount.Name);

        List<Id> contactAlreadyUsed = new List <Id>();
        contactFound = new List<duplicateContacts> ();

        if(EventBookingRecords[index].ContactId == null)
        {
        
            integer cnt = 0;
            for(EventBookingRecs e : EventBookingRecords)
            {
                if(EventBookingRecords[index].bookingContact.firstname == e.bookingContact.firstname && EventBookingRecords[index].bookingContact.lastname == e.bookingContact.lastname && e.ContactId != null)
                {
                    contactAlreadyUsed.add(e.ContactId);
                }
                cnt++;
            }

            system.debug('contactAlreadyUsed - ' + contactAlreadyUsed);

            List<Contact> nameMatchedContact = [Select Id, Title, FirstName, LastName, Email, Phone, Birthdate, AccountId, account.name From Contact 
                            where account.id = :EventBookingRecords[index].bookingContact.AccountId
                                and FirstName = :EventBookingRecords[index].bookingContact.firstname 
                                and LastName = :EventBookingRecords[index].bookingContact.lastname
                                and (id not in :contactAlreadyUsed)];

            system.debug('nameMatchedContact - ' + nameMatchedContact);

            for(Contact c : nameMatchedContact)
            {
                duplicateContacts dc = new duplicateContacts ();
                dc.contactStatus = 'Exists & Not Used';
                dc.dupContact = c;
                contactFound.add(dc);
            }

            if(contactFound.size() > 0)
            {
                duplicateContacts dc = new duplicateContacts ();
                dc.contactStatus = 'Create New?';
                dc.dupContact = new Contact();
                dc.dupContact.firstname = EventBookingRecords[index].bookingContact.firstname;
                dc.dupContact.lastname = EventBookingRecords[index].bookingContact.lastname;
                dc.dupContact.email = EventBookingRecords[index].bookingContact.email;
                dc.dupContact.title = EventBookingRecords[index].bookingContact.title;
                dc.dupContact.phone = EventBookingRecords[index].bookingContact.phone;
                dc.dupContact.AccountId = EventBookingRecords[index].bookingContact.AccountId;
                contactFound.add(dc);
            }

            if(contactFound.size() > 0)
            {
                cnt = 0;
                for(duplicateContacts dc1 : contactFound)
                {
                    dc1.index = cnt++;
                }
                displayPopup = true;
            }
            system.debug('contactFound - ' + contactFound);
        }
        isNotChanged = false;
    }

    public Pagereference saveData()
    {
        system.debug('saveData');
        system.debug('index - ' + index);

        Set<Contact> updateContacts = new Set<Contact> ();

        Set<Contact> Contacts_s = new Set<Contact> ();
        List<Contact> Contacts_l = new List<Contact> ();

        Set<String> email_s = new Set<String> ();
        List<String> email_l = new List<String> ();
        allSubstitutes = new List<substituteContacts> ();

        for(EventBookingRecs ebr : EventBookingRecords)
        {
            if(ebr.bookingContact.email != null)
            {
                Contacts_s.add(ebr.bookingContact);
                Contacts_l.add(ebr.bookingContact);
                //if(email_s.add(ebr.bookingAccount.id+ebr.bookingContact.email) == false)
                if(email_s.add(ebr.AccountId+ebr.bookingContact.email) == false)
                {
                    email_l.add(ebr.bookingContact.email);
                }
            }
        }

        system.debug('Contacts_s size - ' + Contacts_s.size());
        system.debug('Contacts_l size - ' + Contacts_l.size());
        if(Contacts_s.size() != Contacts_l.size())
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Duplicate Contacts are found on this page'));
            return null;
        }

        system.debug('email_s size - ' + email_s.size());
        system.debug('email_l size - ' + email_l.size());

        if(email_l.size() > 0)
        {
            String dupEmails = '';
            for(String s : email_l)
            {
                dupEmails = dupEmails + ',' + s;
            }
            dupEmails = dupEmails.removeStart(',');
            system.debug('dupEmails - ' + dupEmails);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Duplicate Email found on this page - ' + dupEmails));
            return null;
        }
/*
        for(EventBookingRecs ebr : EventBookingRecords)
        {
            if(ebr.isShow == true)
            {
                system.debug('ebr.bookingContact - ' + ebr.bookingContact);
            }
        }
*/
        for(EventBookingRecs ebr : EventBookingRecords)
        {
            if(ebr.isShow == true && ebr.isSubstitute == false)
            {
                if(!(ebr.EventBooking.get('Status__c') == null && ebr.bookingContact.firstname == null && ebr.bookingContact.lastname == null))
                {
                    if(ebr.EventBooking.get('Status__c') != 'No Show' && ebr.bookingContact.firstname == null)
                    {
                        ebr.bookingContact.firstname.adderror('First Name is Required');
                        return null;
                    }
                    else if(ebr.EventBooking.get('Status__c') != 'No Show' && ebr.bookingContact.lastname == null)
                    {
                        ebr.bookingContact.lastname.adderror('Last Name is Required');
                        return null;
                    }
                    else if(ebr.EventBooking.get('Status__c') == null)        
                    {
                        ebr.EventBooking.adderror('Booking Status is Required for ' + ebr.bookingContact.firstname + ' ' + ebr.bookingContact.lastname );
                        return null;
                    }
                    else if(BSCEvent.Product__r.Require_DOB_on_DCForm__c == true && ebr.bookingContact.Birthdate == null && ebr.EventBooking.get('Status__c') != 'No Show')
                    {
                        ebr.EventBooking.adderror('Date of Birth is Required for ' + ebr.bookingContact.firstname + ' ' + ebr.bookingContact.lastname );
                        return null;
                    }
                    else
                    {
/*
                        system.debug('ebr.bookingContact.email - ' + ebr.bookingContact.email);
                        system.debug('ebr.AccountId - ' + ebr.AccountId);
                        system.debug('ebr.ContactId - ' + ebr.ContactId);
*/
                        if(ebr.ContactId != null || ebr.bookingContact.lastname != null)
                        {
                            ebr.bookingContact.id = ebr.ContactId;
                            updateContacts.add(ebr.bookingContact);
                        }
                    }
                }
            }
        }

        try
        {
            system.debug('Before update');
            upsert new List<Contact>(updateContacts);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }

        for(EventBookingRecs ebr : EventBookingRecords)
        {
/*
            if(ebr.index < 2)
            {
                system.debug('Before Update');
                system.debug('ebr.ContactId - ' + ebr.ContactId);
                system.debug('ebr.bookingContact.Id - ' + ebr.bookingContact.Id);
                system.debug('ebr.bookingContact.email - ' + ebr.bookingContact.email);
            }

            if(ebr.ContactId == null)
            {
                ebr.ContactId = ebr.bookingContact.id;
            }
            if(ebr.bookingContact.id == null)
            {
                ebr.bookingContact.id = ebr.ContactId;
            }

            system.debug('After Update');
            system.debug('ebr.ContactId - ' + ebr.ContactId);
            system.debug('ebr.bookingContact.Id - ' + ebr.bookingContact.Id);
            system.debug('ebr.bookingContact.email - ' + ebr.bookingContact.email);
*/

        }

        system.debug('Second Loop');
        
        List<Special_Event_Booking__c> updateBSCEventBookings = new List<Special_Event_Booking__c> ();
        List<Id> updateBSCEventBookingsIds = new List<Id> ();
        Map<Id, Id> bookingToContactMap = new Map<Id, Id> ();
        
        for(EventBookingRecs ebr : EventBookingRecords)
        {
            //system.debug('ebr - ' + ebr);
            if(ebr.index < 2)
            {
                system.debug('ebr.ContactId - ' + ebr.ContactId);
                system.debug('ebr.bookingContact.Id - ' + ebr.bookingContact.Id);
                system.debug('ebr.bookingContact.email - ' + ebr.bookingContact.email);
            }
            
            if(ebr.ContactId == null)
            {
                ebr.ContactId = ebr.bookingContact.id;
            }
            if(ebr.bookingContact.id == null)
            {
                ebr.bookingContact.id = ebr.ContactId;
            }

            if(ebr.index < 2)
            {
                system.debug('ebr.ContactId - ' + ebr.ContactId);
                system.debug('ebr.bookingContact.Id - ' + ebr.bookingContact.Id);
                system.debug('ebr.bookingContact.email - ' + ebr.bookingContact.email);
            }

            String nameField = (string)ebr.EventBooking.get('name');
            if(ebr.EventBooking.get('name') != null && nameField.indexof('EB-') == 0 && ebr.isSubstitute == false)
            {
                if(ebr.isOdd == true)
                {
                    system.debug('Substitute Contact - ' + ebr.bookingContact);
                    substituteContacts newSubstitute = new substituteContacts();

                    newSubstitute.oldRecord = EventBookingRecords[ebr.index-1];
                    newSubstitute.newRecord = EventBookingRecords[ebr.index];
                    allSubstitutes.add(newSubstitute);
                }
                ebr.EventBooking.put('Contact__c',ebr.bookingContact.id);
                //ebr.ContactId = ebr.bookingContact.id;
                
                if(ebr.EventBooking.get('Status__c') == null)
                {
                    ebr.EventBooking.put('Status__c',ebr.status);
                }
                updateBSCEventBookings.add((Special_Event_Booking__c)ebr.EventBooking);
                updateBSCEventBookingsIds.add(ebr.EventBooking.Id);
                //bookingToContactMap.put(ebr.EventBooking.Id, ebr.bookingContact.id);
                bookingToContactMap.put(ebr.EventBooking.Id, ebr.ContactId);
            }
        }

        List<Special_Event_Unit_Booking__c> updateBSCEventUnitBookings = [SELECT Id, Name, Contact__c, Event_Booking__c, Event_Booking__r.name, Event_Booking__r.contact__c
                                                                            FROM Special_Event_Unit_Booking__c where Event_Booking__c = :updateBSCEventBookingsIds];
                                                                            
        for(Special_Event_Unit_Booking__c seub : updateBSCEventUnitBookings)
        {
            seub.contact__c = bookingToContactMap.get(seub.Event_Booking__c);
        }

        try
        {
            update updateBSCEventBookings;
            update updateBSCEventUnitBookings;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }

        system.debug('Third Loop');
        
        List<Temp_Special_Event_Booking__c> newEventBooking = new List<Temp_Special_Event_Booking__c>();
                
        for(EventBookingRecs ebr : EventBookingRecords)
        {
            String nameField = (string)ebr.EventBooking.get('name');
           
            if(ebr.EventBooking.get('name') == null || (ebr.EventBooking.get('name') != null && nameField.indexof('New-EB-') == 0))
            {
                system.debug('Third loop inside if');
                system.debug('ebr - ' + ebr);
                //system.debug('ebr.bookingAccount.id - ' + ebr.bookingAccount.id);
                system.debug('ebr.AccountId - ' + ebr.AccountId);

                //ebr.AccountId = ebr.bookingAccount.id;
                ebr.bookingAccount.id = ebr.AccountId;
                for(SelectOption s : s_eventAccounts)
                {
                    //if(ebr.bookingAccount.id == s.getValue())
                    if(ebr.AccountId == s.getValue())
                    {
                        ebr.bookingAccount.name = s.getLabel();
                    }
                }
                //ebr.bookingContact.AccountId = ebr.bookingAccount.id;
                ebr.bookingContact.AccountId = ebr.AccountId;
                //ebr.EventBooking.put('Company__c', ebr.bookingAccount.id);
                ebr.EventBooking.put('Company__c', ebr.AccountId);
                //ebr.EventBooking.put('Contact__c', ebr.BookingContact.id);
                ebr.EventBooking.put('Contact__c', ebr.ContactId);
                for(Special_Event_Booking__c seb : BSCEventBookings)
                {
                    //if(seb.Company__c == ebr.bookingAccount.id)
                    if(seb.Company__c == ebr.AccountId)
                    {
                        ebr.EventBooking.put('Opportunity__c', seb.Opportunity__c);
                    }
                }

                if(ebr.EventBooking.id == null)
                {
                    ebr.EventBooking.put('isNew__c', true);
                }
                newEventBooking.add((Temp_Special_Event_Booking__c)ebr.EventBooking);
            }
        }

        try
        {
            upsert newEventBooking;
        }
        catch(Exception ex)
        {
            system.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
            return null;
        }

        if(newEventBooking.size() > 0)
        {
            Map<Id, Temp_Special_Event_Booking__c> newEB = new Map<Id, Temp_Special_Event_Booking__c>();
            newEB.putAll(newEventBooking);

            newEB = new Map<Id, Temp_Special_Event_Booking__c> ([SELECT Id, Name, Company__c, Company__r.name, Contact__c, Special_Event__c, status__c, opportunity__c
                        , Partial_Attendance_Flag__c, Attendance_Notes__c, isNew__c
                        FROM Temp_Special_Event_Booking__c where Id in :newEB.keyset() AND isNew__c = true]);

            EmailTemplate addDelEmail = [SELECT Id, Name, Subject, Body, IsActive, Description, HtmlValue, BrandTemplateId, Markup, NamespacePrefix, TemplateStyle, TemplateType, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Delegate_Addition_Email'];
            system.debug('EmailTemplate email - ' + addDelEmail);

            List<Add_Delegate_Email_Alert_List__c> addDelEmailList = [SELECT Id, Name, Send_Email_To__c FROM Add_Delegate_Email_Alert_List__c];

            if(addDelEmail != null && addDelEmailList != null)
            {
                String body = '<head><style>table, th, tr {border: 1px solid black;border-collapse: collapse;font-size:15px;} tr {padding: 10px;}</style></head>';
                body = body + addDelEmail.htmlValue;
                body = body.replace('Event_Name__c', BSCEvent.Name);
                body = body.replace('StartDate__c', BSCEvent.StartDate__c.format());
                body = body.replace('EndDate__c', BSCEvent.EndDate__c.format());
                body = body.replace('Manager__c', BSCEvent.Owner.name);

                String table = '<br><table style="width:75%"><tr><th>Account Name</th><th>Event Booking Name</th>';
                for(ID tseb : newEB.keyset())
                {
                    Temp_Special_Event_Booking__c t = newEB.get(tseb);
                    table = table + '<tr><th><a href="'+url+'/'+t.Company__c+'">'+t.Company__r.Name+'</a></th>';
                    table = table + '<th><a href="'+url+'/'+t.Id+'">'+t.Name+'</a></th></tr>';
                    t.isNew__c = false;
                }
                table = table + '</table>';
                body = body.replace('Table', table);

                system.debug('EmailTemplate email.Body - ' + body);
                
                List<String> emailList = new List<String> ();
                
                for(Add_Delegate_Email_Alert_List__c ad : addDelEmailList)
                {
                    emailList.add(ad.Send_Email_To__c);
                }

                system.debug('List<String> emailList - ' + emailList);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(addDelEmail.subject);
                mail.setHtmlBody(body);
                mail.setToAddresses(emailList);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('Mail Result - ' + results);

                try
                {
                    upsert newEB.values();
                }
                catch(Exception ex)
                {
                    system.debug(ex);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage()));
                    return null;
                }
            }
        }

        if(allSubstitutes.size() > 0)
        {
            EmailTemplate subDelEmail = [SELECT Id, Name, Subject, Body, IsActive, Description, HtmlValue, BrandTemplateId, Markup, NamespacePrefix, TemplateStyle, TemplateType, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Delegate_Substitution_Email'];
            system.debug('EmailTemplate email - ' + subDelEmail);

            List<Substitute_Delegate_Email_Alert_List__c> subDelEmailList = [SELECT Id, Name, Send_Email_To__c FROM Substitute_Delegate_Email_Alert_List__c];

            if(subDelEmail != null && subDelEmailList != null)
            {
                String body = '<head><style>table, th, tr {border: 1px solid black;border-collapse: collapse;font-size:15px;} tr {padding: 10px;}</style></head>';
                body = body + subDelEmail.htmlValue;
                body = body.replace('Event_Name__c', BSCEvent.Name);
                body = body.replace('StartDate__c', BSCEvent.StartDate__c.format());
                body = body.replace('EndDate__c', BSCEvent.EndDate__c.format());
                body = body.replace('Manager__c', BSCEvent.Owner.name);

                String table = '<br><table style="width:75%"><tr><th>Account Name</th><th>Event Booking Name</th><th>Old Contact</th><th>New Contact</th></tr>';
                for(substituteContacts sc : allSubstitutes)
                {
                    table = table + '<tr><th>'+sc.oldRecord.bookingAccount.Name+'</th>';
                    table = table + '<th><a href="'+url+'/'+sc.oldRecord.EventBooking.Id+'">'+sc.oldRecord.EventBooking.get('Name')+'</a></th>';
                    table = table + '<th><a href="'+url+'/'+sc.oldRecord.ContactId+'">'+sc.oldRecord.bookingContact.firstname+' '+sc.oldRecord.bookingContact.lastname+'</a></th>';
                    table = table + '<th><a href="'+url+'/'+sc.newRecord.ContactId+'">'+sc.newRecord.bookingContact.firstname+' '+sc.newRecord.bookingContact.lastname+'</a></th>';
                }
                table = table + '</table>';
                body = body.replace('Table', table);

                system.debug('EmailTemplate email.Body - ' + body);
                List<String> emailList = new List<String> ();
                
                for(Substitute_Delegate_Email_Alert_List__c sd : subDelEmailList)
                {
                    emailList.add(sd.Send_Email_To__c);
                }

                system.debug('List<String> emailList - ' + emailList);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(subDelEmail.subject);
                mail.setHtmlBody(body);
                mail.setToAddresses(emailList);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('Mail Result - ' + results);
            }
        }

        isNotChanged=true;
        PageReference pageRef = new PageReference('/apex/BSCDelegateCapture?id='+BSCEvent.id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference completeEvent()
    {
        if(BSCEvent.status__c == 'Completed')
        {
            PageReference pageRef = new PageReference('/apex/BSCDelegateCaptureComplete?id='+BSCEvent.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    public PageReference cancelData()
    {
        system.debug('URL');

        PageReference pageRef = new PageReference('/apex/BSCDelegateCapture?id='+BSCEvent.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}