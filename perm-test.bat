SET TENANT=8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd
SET SUBSCRIPTION=5107c0cd-1b38-45e5-ad53-5308aeafd97a
set DEV_CENTER_NAME=myDevCenter3
SET DEV_CENTER_RG=myDevCenterRg
set PROJECT_NAME=myProject
SET PROJECT_RG=myProjectRg
set DEV_CENTER_ID=/subscriptions/%TENANT%/resourceGroups/%DEV_CENTER_RG%/providers/Microsoft.Fidalgo/devcenters/%DEV_CENTER_NAME%

az extension remove -n fidalgo 
az extension add --source %homepath%\downloads\fidalgo-0.1.0-py3-none-any.whl -y 
az cloud set -n AzureCloud 
az login --tenant %TENANT% 
az account set –-subscription %SUBSCRIPTION% 
az group create -l EastUS2 -n %DEV_CENTER_RG% 
az configure --defaults group=%DEV_CENTER_RG% 
az fidalgo admin dev-center create ^
    -n %DEV_CENTER_NAME% ^
    --type SystemAssigned ^
    --subscription %SUBSCRIPTION%

az fidalgo admin dev-center list --output table 
az fidalgo admin dev-center show --dev-center %DEV_CENTER_NAME% 
 
az group create -l EastUS2 -n %PROJECT_RG% 
az fidalgo admin project create ^
    -n %PROJECT_NAME% ^
    --dev-center-id %DEV_CENTER_ID% ^
    -g %PROJECT_RG%

az fidalgo admin network-setting create   
--name "{networkSettingName}"   
--domain-name "{domainName}"   
--domain-username "{domainUsername}"   
--domain-password "{domainPassword}"   
--networking-resource-group-id "{networkingResourceGroupId}"   
--subnet-id "{subnetId}" 
 
az group create -l EastUS2 -n cpc_resources 
az configure --defaults group=cpc_resources 

 REM 
 az fidalgo admin dev-center delete -n %DEV_CENTER_NAME%
