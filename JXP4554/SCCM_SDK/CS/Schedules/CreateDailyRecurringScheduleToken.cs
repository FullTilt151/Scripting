public void CreateDailyRecurringScheduleToken(WqlConnectionManager connection,
                                              int hourDuration,
                                              int daySpan,
                                              string startTime,
                                              bool isGmt)
{
    try
    {
        // Create a new recurring interval schedule object.
        // Note: There are several types of schedule classes available, each defines a different type of schedule.
        IResultObject recurInterval = connection.CreateEmbeddedObjectInstance("SMS_ST_RecurInterval");

        // Populate the schedule properties.
        recurInterval["DayDuration"].IntegerValue = 0;
        recurInterval["HourDuration"].IntegerValue = hourDuration;
        recurInterval["MinuteDuration"].IntegerValue = 0;
        recurInterval["DaySpan"].IntegerValue = daySpan;
        recurInterval["HourSpan"].IntegerValue = 0;
        recurInterval["MinuteSpan"].IntegerValue = 0;
        recurInterval["StartTime"].StringValue = startTime;
        recurInterval["IsGMT"].BooleanValue = isGmt;

        // Creating array to use as a parameters for the WriteToString method.
        List<IResultObject> scheduleTokens = new List<IResultObject>();
        scheduleTokens.Add(recurInterval);

        // Creating dictionary object to pass parameters to the WriteToString method.
        Dictionary<string, object> inParams = new Dictionary<string, object>();
        inParams["TokenData"] = scheduleTokens;

        // Initialize the outParams object.
        IResultObject outParams = null;

        // Call WriteToString method to decode the schedule token.
        outParams = connection.ExecuteMethod("SMS_ScheduleMethods", "WriteToString", inParams);

        // Output schedule token as an interval string.
        // Note: The return value for this method is always 0, so this check is just best practice.
        if (outParams["ReturnValue"].IntegerValue == 0)
        {
            Console.WriteLine("Schedule Token Interval String: " + outParams["StringData"].StringValue);
        }
    }
    catch (SmsException ex)
    {
        Console.WriteLine("Failed. Error: " + ex.InnerException.Message);
    }
}