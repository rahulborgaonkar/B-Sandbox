/*
    This class only has properties to hold the selected reason from transfer or cancellation. 

*/

public class tncReasonData{

    public string reason                                     { get; set; }
    public string reasonNote                                 { get; set; }
    public string cancellationRequestedOn                    { get; set; }
    public boolean needNotes                                 { get; set; }
    public boolean needAttachment                            { get; set; }
    public boolean showError                                 { get; set; }
    public boolean feesToBeApplied                           { get; set; }
    public Id reasonId										 { get; set; }
    public string eventStatus								 { get; set; }
    public string transferRequestedOn                        { get; set; }

}