  --Approvers & Deputy Approvers for Shopping Applications.
  select ApproverName [Approver Name], ApproverEmail [Email], DisplayName [Application], DeputyName [Deputy Approver]
  from tb_Approver APR
  join tb_Applications_Approvers AA on APR.ApproverId = aa.ApproverId
  join tb_Application APP on aa.ApplicationId = app.ApplicationId
  order by ApproverName
