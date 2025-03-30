public void RenameCollection(WqlConnectionManager connection, string collectionID, string name, string comment)
{
    IResultObject collection = connection.GetInstance(string.Format("SMS_Collection.CollectionID='{0}'", collectionID));
    Console.WriteLine("-- Collection {0} --", collectionID);
    Console.WriteLine("Name before: {0}", collection["Name"].StringValue);
    Console.WriteLine("Comment before: {0}", collection["Comment"].StringValue);
    collection["Name"].StringValue = name;
    collection["Comment"].StringValue = comment;
    collection.Put();
    collection.Get();
    Console.WriteLine(); 
    Console.WriteLine("Name after: {0}", collection["Name"].StringValue); 
    Console.WriteLine("Comment after: {0}", collection["Comment"].StringValue);
}