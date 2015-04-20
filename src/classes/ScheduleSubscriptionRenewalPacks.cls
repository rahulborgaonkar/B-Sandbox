global class ScheduleSubscriptionRenewalPacks  implements Schedulable {

    global void execute(SchedulableContext SC) {
        SubscriptionRenewal.printReminders();
    }
}