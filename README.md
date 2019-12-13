# General Information #

**This package will be published and synchroniezd to [github](https://github.com/cape-it).**



# Package Description

The survey process consists of one activity which provides an activity dialog only accessible via the customer frontend. In this dialog it is possible to enter a satisfaction grade (1...5) and a remark. If additional data should be collected, you may add own dynamic fields. Be aware that the process definition is updated on package re-/installation and update.

The package creates following dynmic fields which are used in the survey process:

- CustomerSatisfactionStatus
- CustomerSatisfactionGrade
- CustomerStatisfactionRemark
- CSPMProcessID
- CSPMActivityID
- CustomerSatisfactionSurveyEndDate

The survey process is started by a generic agent "Survey Process - Start Survey" which calls a custom generic agent module (`Kernel::System::GenericAgent::SurveyProcessStart`). An existing process-/activity assignment is stored in two dynamic fields. The survey process is ended by setting DF "CustomerSatisfactionStatus" to "done" (set in process activity) or "canceled" (set by generic agent "Survey Process - Abort Survey"). A ticket event handler then restores a previously set process-/activity-assignment. Generic agent definitions are recreated upon package re-/installation and update.

If not altered a survey can be taken as long as the generic agent "Survey Process - Abort Survey" does not cancel the survey. The generic agent definition is recreated upon package re-/installation and update.

The ticket customer receives an event based ticket notification "Survey Process - Customer Satisfaction Survey" which is also created/updated automatically upon package re-/installation and update.

The naming of dynamic fields "CustomerSatisfactionStatus", "CustomerSatisfactionSurveyEndDate" must not be altered, since it is used in the process definition and the generic agents or event handlers code. However the naming of "CSPMProcessID" or "CSPMActivityID" can be changed if the corresponding SysConfig settings are updated as well.

## Notes ##
The package provides five configuration options which can be set in SysConfig.

## Requirements ##
This package requires KIX17 and higher.

## Included Hotfixes ##
- none

## Differentiation ##


## Installation and Upgrade ###

### Installation ###

#### Preparation Installation ####
- none

#### Package Installation ####
- installation via Admin-GUI by uploading the package
- installation via command line interface (replace x.y.z by actual version number):
`root@kix:/opt/kix# sudo -u www-data ./bin/kix.Console.pl Admin::Package::Install /tmp/DFITSMConfigItemReferenceFetchCIAttributes-x.y.z.opm `

#### Postprocessing Installation ####
- activate process in admin-GUI (http://FQDN/ScriptAlias/index.pl?Action=AdminProcessManagement)
- configure Generic Agent "Survey Process - Start Survey" to relevant ticket states if not "closed un-/successful" is used
- set up participation probability via SysConfig `SurveyProcess::ParticipationProbability`if not every ticket should cause a survey request
- set up max. pending time for servey input via SysConfig `SurveyProcess::ParticipationDuration` if less/more than 21 days

### Upgrade ###

#### Package Upgrade ####
- upgrade via Admin-GUI by uploading the package
- Upgrade via command line interface (replace x.y.z by actual version number):
`root@kix:/opt/kix# sudo -u www-data ./bin/kix.Console.pl Admin::Package::Upgrade /tmp/SurveyProcess-x.y.z.opm `

#### Postprocessing Installation ####
- re configure Generic Agents "Survey Process - Start Survey" and "Survey Process - Abort Survey" since they are reset during package upgrade


