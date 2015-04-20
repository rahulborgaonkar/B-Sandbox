/*

VS : This class changes the financial force active company at runtime.
     ffBSCId and ffCWId are the queue ids
     
     if the schedule executing user is in BSC use the following code to change company to Comply wise
            AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF British Safety Council');
            
     if the schedule executing user is in Complywise use the following code to change company to Comply wise
            AutoSwitchFFCompany.switchFFCompany(userinfo.getUserId(), 'FF Complywise Ltd');
            
     CALLING THE PAGEREFERENCE IS PARAMOUNT HERE AS THIS RELEASES THE OLD SETTING AND FINDS WHAT THE ACTIVE COMPANY IS
            PageReference prg = new pagereference('apex/c2g__codacurrentcompanydisplay');
            
     the method switchFFCompany in this class is only called from 
            AutoInvoiceBatch.start()
*/

public class AutoSwitchFFCompany {
    
    public static string switchFFCompany(id userId, string companyName){
        
        id ffBSCId = id.valueof('00GD0000001GWrG');
        id ffCWId = id.valueof('00GD0000001GWsE');
        boolean insertQueue = false;
        
        list<GroupMember> ffGM = [Select Group.Name 
                                    From GroupMember g 
                                   where UserOrGroupId = :userId 
                                     and Group.Name = :companyName]; 
        
        GroupMember newQueueUser = new GroupMember();
        
        if (ffGM.size() == 1 && ffGM[0].Group.Name == 'FF British Safety Council'){
            system.debug('Changing user: ' + userId + ' to use ComplyWise FF Company');
            delete ffGM[0];
            newQueueUser.UserOrGroupId = userId;
            newQueueUser.GroupId = ffCWId;
            insertQueue = true;
        } 
        
        if (ffGM.size() == 1 && ffGM[0].Group.Name == 'FF Complywise Ltd'){
            system.debug('Changing user: ' + userId + ' to use BSC FF Company');
            delete ffGM[0];
            newQueueUser.UserOrGroupId = userId;
            newQueueUser.GroupId = ffBSCId;
            insertQueue = true;
        }
        
        if (insertQueue)
            Insert newQueueUser;
            
         list<string> info = new list<string>();
        info.add(AutoInvoiceSettings.emailNotificationTo);
        
        AutoInvoiceHelper.sendMail('Auto switch Company', 'Old Company: ' + companyName+ 'New Company: ' + c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName, info);
        
        PageReference prg = new pagereference('apex/c2g__codacurrentcompanydisplay');
        
        AutoInvoiceHelper.sendMail('Auto switch Company1', 'Old Company: ' + companyName+ 'New Company: ' + c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName, info);
        
        return c2g.CODACurrentCompanyDisplayController.getCompanyName().companyName;
        
    }
}