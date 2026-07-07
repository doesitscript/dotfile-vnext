Nothing to touch production

Enterprise-integration account or another bucket in Harness account

Resource Allocation
Building out the pipeline - Not Devops Team? to do this?  (I believe they had someone in mind?)

Enable permission for pipeline - Devops Team

Pre-question research:
Search through repositories for code that sets up: 1.  harness 2. sets up harness pipeliens

REquirements and Questions:

1. I want a list of all resource mentioned, alist of current tools that may use them, or plan to use them (designate in parenthesis which it is "plan to" or "currently use" them), accounts that the resource may exist in (leave blank if unclear), or tools that they may exist in (ie if the resouce mentioned lives in harness)
2. Interrum for cli commands (I believe that this would affect the permissions that we create): 
   1.  in the short term (somethign just to get them um an drunning) 
   2. long term (once they figure out what cli commands they ned to trigger from the pipeline (blocked by getting initial access)\[1\]
      1. Note \[1\] Would this mean that we need to giv them access to their profile  they use when accessing the account that has harness so that they can use the AWS Transform? Follow up to this, should we check if thye have access to the admin account which would likely give them access to aws transform and aws kiro?
3. Open question: Harness AppDeploy account accessing the enterprise-integration S3 bucket, or should a new bucket be created in the Harness account? 
   1. CHatgpt: Q1: can you see if there is a pattern that exists for the this bucket for existing services that may be using this bucket? Q2: What is the best practie for multple serices managed by a sdlc in a pipeline when it comes to using buckets? do they get their own? or should they share a bucket? for this customer: he is one of many database teams; so many more will be oming later. Q2.1: how do data pipelines (from mainfraim( liek this use bucket/buckets? What re the options (show me in terms of how they scale by showing me patterns of used to scale out to mutliple data pipelines (more than one team/mainframe in the future) 
