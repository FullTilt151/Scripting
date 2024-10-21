public void ReadCollectionProperties(WqlConnectionManager connection, string collectionID)
{
    IResultObject collection = connection.GetInstance(string.Format("SMS_Collection.CollectionID='{0}'", collectionID));
    string statusText = "None";
    Console.WriteLine("Processing Collection - " + collectionID);
    Console.WriteLine("-- Name: " + collection["Name"].StringValue);
    Console.WriteLine("-- Comment: " + collection["Comment"].StringValue);
    Console.WriteLine("-- Members: " + collection["MemberCount"].IntegerValue.ToString());
    switch (collection["CurrentStatus"].IntegerValue)
    {
        case 1:
            statusText = "Ready";
            break;
        case 2:
            statusText = "Refreshing";
            break;
        case 5:
            statusText = "Awaiting Refresh"; break;
        default:
            break;
    }
    Console.WriteLine("-- Status: " + statusText);
}