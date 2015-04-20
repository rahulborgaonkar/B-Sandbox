global class ScheduleCreateInvoice implements Schedulable {
	
	global void execute(SchedulableContext SC) {
		BatchCreateInvoices batch = new BatchCreateInvoices(0);
		Database.executeBatch(batch, 1);
	}
}