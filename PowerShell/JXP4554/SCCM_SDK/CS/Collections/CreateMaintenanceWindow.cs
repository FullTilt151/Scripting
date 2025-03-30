public void CreateMaintenanceWindow(WqlConnectionManager connection,
                                    string targetCollectionID,
                                    string newMaintenanceWindowName,
                                    string newMaintenanceWindowDescription,
                                    string newMaintenanceWindowServiceWindowSchedules,
                                    bool newMaintenanceWindowIsEnabled,
                                    int newMaintenanceWindowServiceWindowType)
{
    try
    {
        // Create an object to hold the collection settings instance (used to check whether a collection settings instance exists). 
        IResultObject collectionSettingsInstance = null;

        // Get the collection settings instance for the targetCollectionID.
        IResultObject allCollectionSettings = connection.QueryProcessor.ExecuteQuery("Select * from SMS_CollectionSettings where CollectionID='" + targetCollectionID + "'");

        // Enumerate the allCollectionSettings collection (there should be just one item) and save the instance.
        foreach (IResultObject collectionSetting in allCollectionSettings)
        {
            collectionSettingsInstance = collectionSetting;
        }

        // If a collection settings instance does not exist for the target collection, create one.
        if (collectionSettingsInstance == null)
        {
            collectionSettingsInstance = connection.CreateInstance("SMS_CollectionSettings");
            collectionSettingsInstance["CollectionID"].StringValue = targetCollectionID;
            collectionSettingsInstance.Put();
            collectionSettingsInstance.Get();
        }

        // Create a new array list to hold the service window object.
        List<IResultObject> tempServiceWindowArray = new List<IResultObject>();

        // Create and populate a temporary SMS_ServiceWindow object with the new maintenance window values.
        IResultObject tempServiceWindowObject = connection.CreateEmbeddedObjectInstance("SMS_ServiceWindow");

        // Populate temporary SMS_ServiceWindow object with the new maintenance window values.
        tempServiceWindowObject["Name"].StringValue = newMaintenanceWindowName;
        tempServiceWindowObject["Description"].StringValue = newMaintenanceWindowDescription;
        tempServiceWindowObject["ServiceWindowSchedules"].StringValue = newMaintenanceWindowServiceWindowSchedules;
        tempServiceWindowObject["IsEnabled"].BooleanValue = newMaintenanceWindowIsEnabled;
        tempServiceWindowObject["ServiceWindowType"].IntegerValue = newMaintenanceWindowServiceWindowType;

        // Populate the local array list with the existing service window objects (from the target collection).
        tempServiceWindowArray = collectionSettingsInstance.GetArrayItems("ServiceWindows");

        // Add the newly created service window object to the local array list.
        tempServiceWindowArray.Add(tempServiceWindowObject);

        // Replace the existing service window objects from the target collection with the temporary array that includes the new service window.
        collectionSettingsInstance.SetArrayItems("ServiceWindows", tempServiceWindowArray);

        // Save the new values in the collection settings instance associated with the target collection.
        collectionSettingsInstance.Put();
    }
    catch (SmsException ex)
    {
        Console.WriteLine("Failed. Error: " + ex.InnerException.Message);
        throw;
    }
}