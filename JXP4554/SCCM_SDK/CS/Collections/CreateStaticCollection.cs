public void CreateStaticCollection(WqlConnectionManager connection, string newCollectionName, string newCollectionComment, bool ownedByThisSite, string resourceClassName, int resourceID, string limitToCollectionID)
{
    try
    {
        // Create a new SMS_Collection object.
        IResultObject newCollection = connection.CreateInstance("SMS_Collection");

        // Populate new collection properties.
        newCollection["Name"].StringValue = newCollectionName;
        newCollection["Comment"].StringValue = newCollectionComment;
        newCollection["OwnedByThisSite"].BooleanValue = ownedByThisSite;
        newCollection["LimitToCollectionID"].StringValue = limitToCollectionID; 

        // Save the new collection object and properties.  
        // In this case, it seems necessary to 'get' the object again to access the properties.  
        newCollection.Put();
        newCollection.Get();

        // Create a new static rule object.
        IResultObject newStaticRule = connection.CreateInstance("SMS_CollectionRuleDirect");
        newStaticRule["ResourceClassName"].StringValue = resourceClassName;
        newStaticRule["ResourceID"].IntegerValue = resourceID;

        // Add the rule. Although not used in this sample, staticID contains the query identifier.                   
        Dictionary<string, object> addMembershipRuleParameters = new Dictionary<string, object>();
        addMembershipRuleParameters.Add("collectionRule", newStaticRule);
        IResultObject staticID = newCollection.ExecuteMethod("AddMembershipRule", addMembershipRuleParameters);

        // Start collection evaluator.
        Dictionary<string, object> requestRefreshParameters = new Dictionary<string, object>();
        requestRefreshParameters.Add("IncludeSubCollections", false);
        newCollection.ExecuteMethod("RequestRefresh", requestRefreshParameters);

        // Output message.
        Console.WriteLine("Created collection" + newCollectionName);
    }

    catch (SmsException ex)
    {
        Console.WriteLine("Failed to create collection. Error: " + ex.Message);
        throw;
    }
}