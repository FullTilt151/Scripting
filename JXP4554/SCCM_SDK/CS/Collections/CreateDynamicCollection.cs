public void CreateDynamicCollection(WqlConnectionManager connection, string newCollectionName, string newCollectionComment, bool ownedByThisSite, string query, string ruleName, string LimitToCollectionID)
{
    try
    {
        // Create new SMS_Collection object.
        IResultObject newCollection = connection.CreateInstance("SMS_Collection");
        // Populate the new collection object properties.        
        newCollection["Name"].StringValue = newCollectionName;
        newCollection["Comment"].StringValue = newCollectionComment;
        newCollection["OwnedByThisSite"].BooleanValue = ownedByThisSite;
        newCollection["LimitToCollectionID"].StringValue = LimitToCollectionID;
        // Save the new collection object and properties.        
        // In this case, it seems necessary to 'get' the object again to access the properties.        
        newCollection.Put();
        newCollection.Get();
        // Validate the query.        
        Dictionary<string, object> validateQueryParameters = new Dictionary<string, object>();
        validateQueryParameters.Add("WQLQuery", query);
        IResultObject result = connection.ExecuteMethod("SMS_CollectionRuleQuery", "ValidateQuery", validateQueryParameters);
        // Create query rule.        
        IResultObject newQueryRule = connection.CreateInstance("SMS_CollectionRuleQuery");
        newQueryRule["QueryExpression"].StringValue = query;
        newQueryRule["RuleName"].StringValue = ruleName;
        // Add the rule. Although not used in this sample, QueryID contains the query identifier.                           
        Dictionary<string, object> addMembershipRuleParameters = new Dictionary<string, object>();
        addMembershipRuleParameters.Add("collectionRule", newQueryRule);
        IResultObject queryID = newCollection.ExecuteMethod("AddMembershipRule", addMembershipRuleParameters);
        // Start collection evaluator.        newCollection.ExecuteMethod("RequestRefresh", null);        
        Console.WriteLine("Created collection: " + newCollectionName);
    }
    catch (SmsException ex)
    {
        Console.WriteLine("Failed to create collection. Error: " + ex.Message);
        throw;
    }
}