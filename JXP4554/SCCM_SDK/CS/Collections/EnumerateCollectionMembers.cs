public void EnumerateCollectionMembers(WqlConnectionManager connection)
{
    // Set required variables.
    // Note:  Values must be manually added to the queries below.

    try
    {
        // The following example shows how to enumerate the members of the All Systems (SMS00001) collection.
        string Query1 = "SELECT ResourceID FROM SMS_FullCollectionMembership WHERE CollectionID = 'SMS00001'";

        // Run query.
        IResultObject ListOfResources1 = connection.QueryProcessor.ExecuteQuery(Query1);

        // The query returns a collection that needs to be enumerated.
        Console.WriteLine(" ");
        Console.WriteLine("Query: " + Query1);
        foreach (IResultObject Resource1 in ListOfResources1)
        {
            Console.WriteLine(Resource1["ResourceID"].IntegerValue);
        }

        // A slower alternative is to use the SMS_CollectionMember_a association class.
        string Query2 = "SELECT ResourceID FROM SMS_CollectionMember_a WHERE CollectionID = 'SMS00001'";

        // Run query.
        IResultObject ListOfResources2 = connection.QueryProcessor.ExecuteQuery(Query2);

        // The query returns a collection that needs to be enumerated.
        Console.WriteLine(" ");
        Console.WriteLine("Query: " + Query2);
        foreach (IResultObject Resource2 in ListOfResources2)
        {
            Console.WriteLine(Resource2["ResourceID"].IntegerValue);
        }

        // A further alternative is to query the members by using the actual collection class name specified in the MemberClassName property of SMS_Collection.
        string Query3 = "SELECT ResourceID FROM SMS_CM_Res_Coll_SMS00001";

        // Run query.
        IResultObject ListOfResources3 = connection.QueryProcessor.ExecuteQuery(Query3);

        // The query returns a collection that needs to be enumerated.
        Console.WriteLine(" ");
        Console.WriteLine("Query: " + Query3);
        foreach (IResultObject Resource3 in ListOfResources3)
        {
            Console.WriteLine(Resource3["ResourceID"].IntegerValue);
        }
    }

    catch (SmsException eX)
    {
        Console.WriteLine("Failed to run queries. Error: " + eX.Message);
        throw;
    }
}