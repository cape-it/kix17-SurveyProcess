# General Information #
* [OPM-Repository](http://git.intra.cape-it.de:8088/builds/Customerprojects/Generic/SurveyProcess/)

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
