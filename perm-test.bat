SET TENANT=8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd
SET SUBSCRIPTION=5107c0cd-1b38-45e5-ad53-5308aeafd97a

SET LOCATION=EastUS2
SET DEV_CENTER_NAME=myDevCenter3
SET DEV_CENTER_RG=myDevCenterRg
SET DEV_CENTER_ID=/subscriptions/%SUBSCRIPTION%/resourceGroups/%DEV_CENTER_RG%/providers/Microsoft.Fidalgo/devcenters/%DEV_CENTER_NAME%

SET NETWORK_SETTINGS_NAME=myNetworkSetting
SET NETWORK_SETTINGS_ID=/subscriptions/%SUBSCRIPTION%/resourceGroups/%DEV_CENTER_RG%/providers/Microsoft.Fidalgo/networksettings/%NETWORK_SETTINGS_NAME%
SET DOMAIN_NAME=fidalgoppe010.local
SET DOMAIN_USER_NAME=domainjoin
SET DOMAIN_PASSWORD=****
SET CPC_RG=/subscriptions/5107c0cd-1b38-45e5-ad53-5308aeafd97a/resourceGroups/myCpcRg
SET SUBNET_ID=/subscriptions/%SUBSCRIPTION%/resourceGroups/permtest/providers/Microsoft.Network/virtualNetworks/vNetPermTest/subnets/default

SET MACHINE_DEFINITION_NAME=myMachineDefinition
SET MACHINE_DEFINITION_ID=/subscriptions/%SUBSCRIPTION%/resourceGroups/%DEV_CENTER_RG%/providers/Microsoft.Fidalgo/machinedefinitions/%MACHINE_DEFINITION_NAME%

SET POOL_NAME=myPoolName

SET PROJECT_ID=/subscriptions/%SUBSCRIPTION%/resourceGroups/%DEV_CENTER_RG%/providers/Microsoft.Fidalgo/projects/%PROJECT_NAME%
SET PROJECT_NAME=myProject

SET DEVELOPER_EMAIL=chrkin@fidalgoppe010.onmicrosoft.com
SET DEVELOPER_PASSWORD=****
SET VM_NAME=myVm

az extension remove -n fidalgo 
az extension add --source %homepath%\downloads\fidalgo-0.1.0-py3-none-any.whl -y 
az cloud set -n AzureCloud 
az login --tenant %TENANT% 
az account set –-subscription %SUBSCRIPTION% 
az group create -l %LOCATION% -n %DEV_CENTER_RG% 
az configure --defaults group=%DEV_CENTER_RG% 
az fidalgo admin dev-center create ^
    -n %DEV_CENTER_NAME% ^
    --type SystemAssigned ^
    --subscription %SUBSCRIPTION%

az fidalgo admin dev-center list --output table 
az fidalgo admin dev-center show --dev-center %DEV_CENTER_NAME% 
 
az fidalgo admin project create ^
    -n %PROJECT_NAME% ^
    --dev-center-id %DEV_CENTER_ID% ^
    -g %DEV_CENTER_RG%
az fidalgo admin project list -g %DEV_CENTER_RG%
az fidalgo admin project delete -g %DEV_CENTER_RG% -n %PROJECT_NAME%

az group create -l %LOCATION% -n %CPC_RG% 
az fidalgo admin network-setting create ^
    --name %NETWORK_SETTINGS_NAME% ^
    --domain-name "%DOMAIN_NAME%" ^
    --domain-username "%DOMAIN_USER_NAME%" ^
    --domain-password "%DOMAIN_PASSWORD%" ^
    --networking-resource-group-id %CPC_RG% ^
    --subnet-id %SUBNET_ID% ^
    -g %DEV_CENTER_RG%

az fidalgo admin network-setting show -g %DEV_CENTER_RG% --name %NETWORK_SETTINGS_NAME%
az fidalgo admin network-setting show-health-detail -g %DEV_CENTER_RG% --name %NETWORK_SETTINGS_NAME%

az ad sp list --all --query "[?appId=='0af06dc6-e4b5-4f28-818e-e78e62d137a5'].{DisplayName:displayName, ObjectId:objectId}" 
az fidalgo admin machine-definition create ^
    --location %LOCATION% ^
    --resource-group %DEV_CENTER_RG% ^
    --name %MACHINE_DEFINITION_NAME% ^
    --image-reference publisher=MicrosoftWindowsDesktop offer=windows-ent-cpc sku=19h2-ent-cpc-os-g2
az fidalgo admin machine-definition list

REM az fidalgo admin sku list 
az fidalgo admin pool create ^
    --location %LOCATION% ^
    --resource-group %DEV_CENTER_RG% ^
    --project-name %PROJECT_NAME% ^
    --name %POOL_NAME% ^
    --machine-definition-id %MACHINE_DEFINITION_ID% ^
    --network-settings-id %NETWORK_SETTINGS_ID% ^
    --sku name="Dogfood"
az fidalgo admin pool list --project-name %PROJECT_NAME%

az role assignment create ^
    --subscription %SUBSCRIPTION% ^
    --assignee "%DEVELOPER_EMAIL%" ^
    --role "Contributor" ^
    --scope %PROJECT_ID% 
az role assignment list ^
    --subscription %SUBSCRIPTION% ^
    --assignee "%DEVELOPER_EMAIL%" ^
    --scope %PROJECT_ID% 

az login

az fidalgo dev project list ^
    --dev-center %DEV_CENTER_NAME%

az fidalgo dev pool list ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME%

az fidalgo dev virtual-machine create ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    --pool-name %POOL_NAME% ^
    -n %VM_NAME%

az fidalgo dev virtual-machine show ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    -n %VM_NAME%

az fidalgo dev virtual-machine stop ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    -n %VM_NAME%

az fidalgo dev virtual-machine start ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    -n %VM_NAME%
 
az fidalgo dev virtual-machine get-rdp-file-content ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    -n %VM_NAME%

REM 
az fidalgo admin dev-center delete -g %DEV_CENTER_RG% -n %DEV_CENTER_NAME%
az fidalgo admin project delete -g %DEV_CENTER_RG% --project %PROJECT_NAME%
az fidalgo admin machine-definition delete --resource-group %DEV_CENTER_RG% --name %MACHINE_DEFINITION_NAME%

az fidalgo dev virtual-machine delete ^
    --dev-center %DEV_CENTER_NAME% ^
    --project-name %PROJECT_NAME% ^
    -n %VM_NAME%
