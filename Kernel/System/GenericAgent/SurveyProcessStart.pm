# --
# Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::GenericAgent::SurveyProcessStart;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Time'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless $Self, $Type;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed object
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TimeObject                = $Kernel::OM->Get('Kernel::System::Time');

    # get config - processID + activityID
    my $SPProcessID = $ConfigObject->Get("SurveyProcess::ProcessID")   || '';
    my $SPActivityID = $ConfigObject->Get("SurveyProcess::ActivityID") || '';

    # get config - DF for storage of current process assignment
    my $DFSPProcessID  = $ConfigObject->Get("SurveyProcess::DynamicFieldProcessManagementProcessID")  || 'CSPMProcessID';
    my $DFSPActivityID = $ConfigObject->Get("SurveyProcess::DynamicFieldProcessManagementActivityID") || 'CSPMActivityID';

    # get config - DF for assigned process+activity
    my $DFProcessID  = $ConfigObject->Get("Process::DynamicFieldProcessManagementProcessID")  || 'ProcessManagementProcessID';
    my $DFActivityID = $ConfigObject->Get("Process::DynamicFieldProcessManagementActivityID") || 'ProcessManagementActivityID';

    my $Probability = $ConfigObject->Get("SurveyProcess::ParticipationProbability") || '0';
    my $CSStatus    = $ConfigObject->Get("SurveyProcess::DynamicFieldCustomerSatisfactionStatus") || 'requested';
    my $CSDuration  = $ConfigObject->Get("SurveyProcess::ParticipationDuration") || '0';

    my $Success = 0;

    if( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'TicketID not given!',
        );
        return 0;
    }

    if ( !$Probability ) {
        return;
    }
    elsif( $Probability < "100" && $Probability < int(rand(100)) ) {
        return;
    }

    # get ticket data...
    my %TicketData = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        UserID        => 1,
        Silent        => 0,
    );

    # --------------------------------------------------------------------------
    # set DF CustomerSatisfactionStatus
    my $DFConfigCSStatus = $DynamicFieldObject->DynamicFieldGet(
        Name => 'CustomerSatisfactionStatus',
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigCSStatus,
        ObjectID           => $Param{TicketID},
        Value              => $CSStatus,
        UserID             => 1,
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update DF <CustomerSatisfactionStatus> in TID <' . $Param{TicketID} . '>'
        );
    }

    # --------------------------------------------------------------------------
    # calculate last day of survey participation...
    if ( $CSDuration ) {
        my $LastSurveyDateTimeStamp = $TimeObject->SystemTime2TimeStamp(
            SystemTime => $TimeObject->SystemTime() + ($CSDuration * 86400),
        );
        # set time to 00:00:00 that day (to avoid unrequired precision)
        $LastSurveyDateTimeStamp =~ s/\d\d\:\d\d:\d\d/00:00:00/g;
        my $DFConfigCSSEndDate = $DynamicFieldObject->DynamicFieldGet(
            Name => 'CustomerSatisfactionSurveyEndDate',
        );
        $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DFConfigCSSEndDate,
            ObjectID           => $Param{TicketID},
            Value              => $LastSurveyDateTimeStamp,
            UserID             => 1,
        );
        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Could not update DF <CustomerSatisfactionSurveyEndDate> in TID <' . $Param{TicketID} . '>'
            );
        }
    }


    # --------------------------------------------------------------------------
    # remember the current process and process activity...
    if( $TicketData{'DynamicField_'.$DFProcessID} && $TicketData{'DynamicField_'.$DFActivityID} ) {

        # store current process ID...
        my $DFConfigSPProcessID = $DynamicFieldObject->DynamicFieldGet(
            Name => $DFSPProcessID,
        );
        $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DFConfigSPProcessID,
            ObjectID           => $Param{TicketID},
            Value              => $TicketData{'DynamicField_'.$DFProcessID} || '',
            UserID             => 1,
        );
        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Could not update DF <'.$DFSPProcessID.'> in TID <' . $Param{TicketID} . '>'
            );
        }

        # store current activity ID...
        my $DFConfigSPActivityID = $DynamicFieldObject->DynamicFieldGet(
            Name => $DFSPActivityID,
        );
        $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DFConfigSPActivityID,
            ObjectID           => $Param{TicketID},
            Value              => $TicketData{'DynamicField_'.$DFSPActivityID} || '',
            UserID             => 1,
        );
        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Could not update DF <'.$DFSPActivityID.'> in TID <' . $Param{TicketID} . '>'
            );
        }
    }


    # --------------------------------------------------------------------------
    # assigning the survey process...

    # set DF process...
    my $DFConfigProcessID = $DynamicFieldObject->DynamicFieldGet(
        Name => $DFProcessID,
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigProcessID,
        ObjectID           => $Param{TicketID},
        Value              => $SPProcessID || '',
        UserID             => 1,
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update DF <'.$DFProcessID.'> in TID <' . $Param{TicketID} . '>'
        );
    }

    # set DF activity...
    my $DFConfigActivityID = $DynamicFieldObject->DynamicFieldGet(
        Name => $DFActivityID,
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigActivityID,
        ObjectID           => $Param{TicketID},
        Value              => $SPActivityID || '',
        UserID             => 1,
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update DF <'.$DFConfigActivityID.'> in TID <' . $Param{TicketID} . '>'
        );
    }

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the KIX project
(L<http://www.kixdesk.com/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see the enclosed file
COPYING for license information (AGPL). If you did not receive this file, see

<http://www.gnu.org/licenses/agpl.txt>.

=cut
