Connect-AzAccount -Tenant

Get-AzContext

#get object Id of the current user (that is used above)
$user = Get-AzADUser -UserPrincipalName (Get-AzContext).Account

#assign Owner role at Tenant root scope ("/") as a User Access Administrator to current user
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id#### Management Groups



#### Management Groups ####

$inputObject = @{
    DeploymentName        = 'alz-MGDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location              = 'norwayeast'
    TemplateFile          = "infra-as-code/bicep/modules/managementGroups/managementGroups.bicep"
    TemplateParameterFile = 'infra-as-code/bicep/modules/managementGroups/parameters/managementGroups.parameters.all.json'
  }
New-AzTenantDeployment @inputObject














#### Custom Policy Definitions ####

$inputObject = @{
    DeploymentName        = 'alz-PolicyDefsDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location              = 'norwayeast'
    ManagementGroupId     = 'mtc'
    TemplateFile          = "infra-as-code/bicep/modules/policy/definitions/customPolicyDefinitions.bicep"
    TemplateParameterFile = 'infra-as-code/bicep/modules/policy/definitions/parameters/customPolicyDefinitions.parameters.all.json'
  }

New-AzManagementGroupDeployment @inputObject









#### Custom roles ####

$inputObject = @{
    DeploymentName        = 'alz-CustomRoleDefsDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location              = 'norwayeast'
    ManagementGroupId     = 'mtc'
    TemplateFile          = "infra-as-code/bicep/modules/customRoleDefinitions/customRoleDefinitions.bicep"
    TemplateParameterFile = 'infra-as-code/bicep/modules/customRoleDefinitions/parameters/customRoleDefinitions.parameters.all.json'
  }

New-AzManagementGroupDeployment @inputObject










#### Logging ####

# Set the top level MG Prefix in accordance to your environment.
$TopLevelMGPrefix = "mtc"

$inputObject = @{
    DeploymentName        = 'alz-LoggingDeploy-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    ResourceGroupName     = "rg-$TopLevelMGPrefix-logging-001"
    TemplateFile          = "infra-as-code/bicep/modules/logging/logging.bicep"
    TemplateParameterFile = "infra-as-code/bicep/modules/logging/parameters/logging.parameters.all.json"
}


# Set Platform management subscription ID as the the current subscription
$ManagementSubscriptionId = "[your platform management subscription ID]"

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

New-AzResourceGroup -Name $inputObject.ResourceGroupName -Location 'norwayeast'

New-AzResourceGroupDeployment @inputObject










#### Hub Networking module ####

# Set the top level MG Prefix in accordance to your environment.
$TopLevelMGPrefix = "mtc"

$inputObject = @{
  DeploymentName        = 'alz-HubNetworkingDeploy-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = "rg-$TopLevelMGPrefix-hub-networking-001"
  TemplateFile          = "infra-as-code/bicep/modules/hubNetworking/hubNetworking.bicep"
  TemplateParameterFile = "infra-as-code/bicep/modules/hubNetworking/parameters/hubNetworking.parameters.all.json"
}

# Set Platform connectivity subscription ID as the the current subscription
$ConnectivitySubscriptionId = "[your platform connectivity subscription ID]"

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzResourceGroup -Name $inputObject.ResourceGroupName -Location 'norwayeast'

New-AzResourceGroupDeployment @inputObject









#### Subscription placement module #### (optional)

$inputObject = @{
    DeploymentName        = 'alz-SubPlacementAll-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location              = 'norwayeast'
    ManagementGroupId     = 'mtc'
    TemplateFile          = "infra-as-code/bicep/orchestration/subPlacementAll/subPlacementAll.bicep"
    TemplateParameterFile = 'infra-as-code/bicep/orchestration/subPlacementAll/parameters/subPlacementAll.parameters.all.json'
  }

  New-AzManagementGroupDeployment @inputObject








#### Policy assignment module ####

$inputObject = @{
    DeploymentName        = 'alz-alzPolicyAssignmentDefaultsDeployment-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    Location              = 'norwayeast'
    ManagementGroupId     = 'mtc'
    TemplateFile          = "infra-as-code/bicep/modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep"
    TemplateParameterFile = 'infra-as-code/bicep/modules/policy/assignments/alzDefaults/parameters/alzDefaultPolicyAssignments.parameters.all.json'
  }

New-AzManagementGroupDeployment @inputObject








#### Custom policy assignment for allowed locations (regions) ####



$inputObject = @{
    DeploymentName        = 'alz-PolicyDenyAssignments-{0}' -f (-join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
    ManagementGroupId     = 'mtc-landingzones'
    Location              = 'norwayeast'
    TemplateParameterFile = 'infra-as-code/bicep/modules/policy/assignments/parameters/policyAssignmentManagementGroup.deny.parameters.all.json'
    TemplateFile          = "infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep"
  }
  New-AzManagementGroupDeployment @inputObject




