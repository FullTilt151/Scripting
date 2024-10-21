public void DeleteCollection(WqlConnectionManager connection, string collectionIDToDelete)
{
    //  Note:  On delete, the provider cleans up the SMS_CollectionSettings and SMS_CollectToSubCollect objects.

    try
    {
        // Get the specific collection instance to delete.
        IResultObject collectionToDelete = connection.GetInstance(@"SMS_Collection.CollectionID='" + collectionIDToDelete + "'");

        // Delete the collection.
        collectionToDelete.Delete();

        // Output the ID of the deleted collection.
        Console.WriteLine("Deleted collection: " + collectionIDToDelete);
    }

    catch (SmsException ex)
    {
        Console.WriteLine("Failed to delete collection. Error: " + ex.Message);
        throw;
    }
}