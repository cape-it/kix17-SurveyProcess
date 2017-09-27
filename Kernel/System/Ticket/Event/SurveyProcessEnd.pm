# --
# Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::SurveyProcessEnd;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item Run()

Run - contains the actions performed by this event handler.

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Data UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need ' . $Needed . '!',
            );
            return;
        }
    }

    for my $Needed (qw(TicketID)) {
        if ( !$Param{Data}->{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need ' . $Needed . ' in Data!'
            );
            return;
        }
    }

    # get needed objects
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');

    if( !$Param{Config}->{EndStatusRegEx} ) {
      $Kernel::OM->Get('Kernel::System::Log')->Log(
          Priority => 'error',
          Message  => 'Config of Event::SurveyProcessEnd is missing <EndStatusRegEx>!',
      );
    }

    # get config - processID + activityID...
    my $SPProcessID = $ConfigObject->Get("SurveyProcess::ProcessID")   || '';
    my $SPActivityID = $ConfigObject->Get("SurveyProcess::ActivityID") || '';

    # get config - DF for storage of current process assignment...
    my $DFSPProcessID  = $ConfigObject->Get("SurveyProcess::DynamicFieldProcessManagementProcessID")  || 'CSPMProcessID';
    my $DFSPActivityID = $ConfigObject->Get("SurveyProcess::DynamicFieldProcessManagementActivityID") || 'CSPMActivityID';

    # get config - DF for assigned process+activity...
    my $DFProcessID  = $ConfigObject->Get("Process::DynamicFieldProcessManagementProcessID")  || 'ProcessManagementProcessID';
    my $DFActivityID = $ConfigObject->Get("Process::DynamicFieldProcessManagementActivityID") || 'ProcessManagementActivityID';

    my $Success = 0;

    # get ticket data...
    my %TicketData = $TicketObject->TicketGet(
        TicketID      => $Param{Data}->{TicketID},
        DynamicFields => 1,
        UserID        => 1,
        Silent        => 0,
    );

    # --------------------------------------------------------------------------
    # check f the survey process did end...
    if( !$TicketData{'DynamicField_CustomerSatisfactionStatus'}
        || ($TicketData{'DynamicField_CustomerSatisfactionStatus'} !~ /$Param{Config}->{EndStatusRegEx}/)
      )
    {
        return 1;
    }

    # --------------------------------------------------------------------------
    # restore previus process-assignment or just clrear current...

    # set DF process...
    my $DFConfigProcessID = $DynamicFieldObject->DynamicFieldGet(
        Name => $DFProcessID,
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigProcessID,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $TicketData{'DynamicField_'.$DFSPProcessID} || '',
        UserID             => 1,
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update DF <'.$DFProcessID.'> in TID <' . $Param{Data}->{TicketID} . '>'
        );
    }

    # set DF activity...
    my $DFConfigActivityID = $DynamicFieldObject->DynamicFieldGet(
        Name => $DFActivityID,
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigActivityID,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => $TicketData{'DynamicField_'.$DFSPActivityID} || '',
        UserID             => 1,
    );
    if ( !$Success ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update DF <'.$DFConfigActivityID.'> in TID <' . $Param{Data}->{TicketID} . '>'
        );
    }

    # set DF process...
    my $DFConfigCSSEndDate = $DynamicFieldObject->DynamicFieldGet(
        Name => 'CustomerSatisfactionSurveyEndDate',
    );
    $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DFConfigCSSEndDate,
        ObjectID           => $Param{Data}->{TicketID},
        Value              => '',
        UserID             => 1,
    );

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
