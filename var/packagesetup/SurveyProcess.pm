# --
# Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::SurveyProcess;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::SysConfig',
    'Kernel::System::CSV',               'Kernel::System::DynamicField',
    'Kernel::System::GeneralCatalog',    'Kernel::System::GenericAgent',
    'Kernel::System::Group',             'Kernel::System::ImportExport',
    'Kernel::System::ITSMConfigItem',    'Kernel::System::KIXUtils',
    'Kernel::System::Log',               'Kernel::System::Main',
    'Kernel::System::NotificationEvent', 'Kernel::System::PostMaster::Filter',
    'Kernel::System::Priority',          'Kernel::System::Signature',
    'Kernel::System::State',             'Kernel::System::Stats',
    'Kernel::System::Type',              'Kernel::System::Valid',
    'Kernel::System::QueuesGroupsRoles', 'Kernel::System::Stats',
);

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {};
    bless( $Self, $Type );

    # create needed sysconfig object...
    $Self->{SysConfigObject} = $Kernel::OM->Get('Kernel::System::SysConfig');
    $Self->{SysConfigObject}->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            if ( !-f $File ) {
                next PREFIX
            }
            do $File;
            last PREFIX;
        }
    }

    # always discard the config object before package code is executed,
    # to make sure that the config object will be created newly, so that it
    # will use the recently written new config from the package
    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    $Self->{ConfigObject}         = $Kernel::OM->Get('Kernel::Config');
    $Self->{DynamicFieldObject}   = $Kernel::OM->Get('Kernel::System::DynamicField');
    $Self->{GeneralCatalogObject} = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    $Self->{LogObject}            = $Kernel::OM->Get('Kernel::System::Log');
    $Self->{MainObject}           = $Kernel::OM->Get('Kernel::System::Main');
    $Self->{StateObject}          = $Kernel::OM->Get('Kernel::System::State');
    $Self->{ValidObject}          = $Kernel::OM->Get('Kernel::System::Valid');
    $Self->{YAMLObject}           = $Kernel::OM->Get('Kernel::System::YAML');
    $Self->{NotificationObject}   = $Kernel::OM->Get('Kernel::System::NotificationEvent');
    $Self->{ProcessObject}        = $Kernel::OM->Get('Kernel::System::ProcessManagement::DB::Process');
    $Self->{KIXUtilsObject}       = $Kernel::OM->Get('Kernel::System::KIXUtils');


    # define valid list
    my %Validlist = $Self->{ValidObject}->ValidList();
    my %TmpHash2  = reverse(%Validlist);
    $Self->{ReverseValidList} = \%TmpHash2;
    $Self->{ValidList}        = \%Validlist;

    # defines list of custom states
    $Self->{CustomStateList} = { };

    # defines ticket types to rename
    $Self->{TicketTypesToRename} = { };

    # define activated ticket types
    $Self->{TicketTypesActive} = { };

    # define file prefix
    $Self->{PackagePrefix} = "SurveyProcess";
    $Self->{FilePrefix} = 'SurveyProcessStats';


    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;
    # register this module as custom module...
    $Self->_RegisterCustomModule();

    # custom code on installation...
    $Self->_ImportQueuesGroupsRoles();
    $Self->_CreateDynamicFields();
    $Self->_UpdateSysConfig();
    $Self->_AddProcessDefinitions( OverwriteExistingEntities => 1 );
    $Self->_NotificationImport();
    $Self->_CreateGenericAgentJobs( OverwriteExistingEntities => 1 );
    $Self->_AddACLsFromFile();
    $Kernel::OM->Get('Kernel::System::Stats')->StatsInstall(
        FilePrefix => $Self->{FilePrefix},
        UserID     => 1,
    );

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;
    # register this module as custom module...
    $Self->_RegisterCustomModule();

    # custom code on installation...
    $Self->_ImportQueuesGroupsRoles();
    $Self->_CreateDynamicFields();
    $Self->_UpdateSysConfig();
    $Self->_AddProcessDefinitions( OverwriteExistingEntities => 1 );
    $Self->_NotificationImport();
    $Self->_CreateGenericAgentJobs( OverwriteExistingEntities => 1 );
    $Self->_AddACLsFromFile();
    $Kernel::OM->Get('Kernel::System::Stats')->StatsInstall(
        FilePrefix => $Self->{FilePrefix},
        UserID     => 1,
    );

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    # register this module as custom module...
    $Self->_RegisterCustomModule();

    # custom code on installation...
    $Self->_ImportQueuesGroupsRoles();
    $Self->_CreateDynamicFields();
    $Self->_UpdateSysConfig();
    $Self->_AddProcessDefinitions( OverwriteExistingEntities => 1 );
    $Self->_NotificationImport();
    $Self->_CreateGenericAgentJobs( OverwriteExistingEntities => 1 );
    $Self->_AddACLsFromFile();
    $Kernel::OM->Get('Kernel::System::Stats')->StatsInstall(
        FilePrefix => $Self->{FilePrefix},
        UserID     => 1,
    );

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    # unregister this module as custom module...
    $Self->_RemoveCustomModule();

    # keep dynamic fields (since this is not our data)

    # remove process definition...
    # TO DO / not required sinc process is started by GenericAgent which will be removed

    # remove ticket notification...
    # TO DO / not required since triggering event is caused by generic agent which will be removed

    # remove generic agents...
    $Self->_RemoveGenericAgentJobs();

    # remove reports...
    $Kernel::OM->Get('Kernel::System::Stats')->StatsUninstall(
        FilePrefix => $Self->{FilePrefix},
        UserID     => 1,
    );

    return 1;
}


#-------------------------------------------------------------------------------
# Internal Functions


# TO DO - !!! REMOVE BEFORE FLIGHT !!!



sub _GetDynamicFieldsDefinition {
    my ( $Self, %Param ) = @_;

    # get CI-classes
    my $CIClassRef = $Self->{GeneralCatalogObject}->ItemList(
        Class => 'ITSM::ConfigItem::Class',
        Valid => 0,
    );
    my %CIClassList        = %{$CIClassRef};
    my %ReverseCIClassList = reverse(%CIClassList);
    my $CCClassID          = $ReverseCIClassList{"Cost Center"} || "";

    # get CI Deployment states...
    my $DeploymentStateRef = $Self->{GeneralCatalogObject}->ItemList(
        Class => 'ITSM::ConfigItem::DeploymentState',
        Valid => 0,
    );
    my %DeploymentStateList        = %{$DeploymentStateRef};
    my %ReverseDeploymentStateList = reverse(%DeploymentStateList);


    # DynamicFields to create
    my @DynamicFields = (
        # fields describing the demand...
        {
            Name       => 'CustomerSatisfactionStatus',
            Label      => 'Survey Status',
            FieldType  => 'Dropdown',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '01: Survey',
            CustomerTicketZoom => '1',
            OverviewSmall => '1',
            Config     => {
                TranslatableValues => '1',
                PossibleNone       => '1',
                PossibleValues     => {
                  'requested' => 'requested',
                  'done'      => 'done',
                  'canceled'  => 'canceled',
                },
            },
        },
        {
            Name       => 'CustomerSatisfactionGrade',
            Label      => 'Satisfaction Grade',
            FieldType  => 'Dropdown',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '01: Survey',
            CustomerTicketZoom => '1',
            OverviewSmall => '1',
            Config     => {
                TranslatableValues => '1',
                PossibleNone       => '1',
                PossibleValues     => {
                  '1 - very good' => '1 - very good',
                  '2 - good'      => '2 - good',
                  '3 - ok'        => '3 - ok',
                  '4 - not so ok' => '4 - not so ok',
                  '5 - bad'       => '5 - bad',
                },
            },
        },
        {
            Name       => 'CustomerStatisfactionRemark',
            Label      => 'Satisfaction Remark',
            FieldType  => 'TextArea',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '01: Survey',
            CustomerTicketZoom => '1',
            OverviewSmall => '0',
            Config     => {
                Cols         => '80',
                Rows         => '5',
            },
        },
        {
            Name       => 'CSPMProcessID',
            Label      => 'CSPMProcessID',
            FieldType  => 'Text',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '',
            CustomerTicketZoom => '0',
            OverviewSmall => '0',
            Config     => {
                DefaultValue => '',
                Link         => '',
            },
        },
        {
            Name       => 'CSPMActivityID',
            Label      => 'CSPMActivityID',
            FieldType  => 'Text',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '',
            CustomerTicketZoom => '0',
            OverviewSmall => '0',
            Config     => {
                DefaultValue => '',
                Link         => '',
            },
        },
        {
            Name       => 'CustomerSatisfactionSurveyEndDate',
            Label      => 'Survey End Date',
            FieldType  => 'Date',
            ObjectType => 'Ticket',
            ProcessWidgetDFGroup => '01: Survey',
            CustomerTicketZoom => '0',
            OverviewSmall => '0',
            Config     => {
                DefaultValue  => '0',
                Link          => '',
                YearsInFuture => '5',
                YearsInPast   => '1',
                YearsPeriod   => '0',
            },
        },


    );

    return @DynamicFields;
}

sub _RegisterCustomModule {
    my ( $Self, %Param ) = @_;

    #---------------------------------------------------------------------------
    # setup multiple cutsom module folders...
    # register ...
    $Self->{KIXUtilsObject}->RegisterCustomPackage(
        PackageName => 'SurveyProcess',
        Priority    => '2001',
    );

    #--------------------------------------------------------------------------
    # reload configuration....
    $Self->{SysConfigObject}->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if ( !-f $File );
            do $File;
            last PREFIX;
        }
    }
    return 1;
}

sub _RemoveCustomModule {
    my ( $Self, %Param ) = @_;

    #---------------------------------------------------------------------------
    # delete all multiple cutsom module folders for ...
    $Self->{KIXUtilsObject}->UnRegisterCustomPackage(
        PackageName => 'SurveyProcess',
    );

    #--------------------------------------------------------------------------
    # reload configuration....
    $Self->{SysConfigObject}->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if ( !-f $File );
            do $File;
            last PREFIX;
        }
    }
    return 1;
}

sub _RemoveGenericAgentJobs {
    my ( $Self, %Param ) = @_;
    my @GenericAgentJobs = qw{};

    # get existing generic agent jobs..
    my %JobList = $Kernel::OM->Get('Kernel::System::GenericAgent')->JobList();

    my $DefFilePath =
        $Self->{ConfigObject}->Get('Home')
      . '/var/packagesetup/InitialSetup/'
      . $Self->{PackagePrefix}
      . '_GenericAgents.yml';

    my $GAConfFileContent = $Self->{MainObject}->FileRead(
        Location => $DefFilePath,
        Result   => 'SCALAR',
        Mode     => 'binmode',
    );

    if ( !$GAConfFileContent || !$$GAConfFileContent ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Couldn't read file <$DefFilePath> or file is empty.",
        );
        return 0;
    }

    my $GADefinitions = $Self->{YAMLObject}->Load( Data => $$GAConfFileContent );

    # delete generic agent jobs installed by package
    for my $GenericAgentRef ( @{$GADefinitions} ) {
        if( $JobList{ $GenericAgentRef->{Name}} ) {
            $Kernel::OM->Get('Kernel::System::GenericAgent')->JobDelete(
              Name   => $GenericAgentRef->{Name},
              UserID => 1,
            );
        }
    }
    return 1;
}

sub _CreateGenericAgentJobs {
    my ( $Self, %Param ) = @_;
    my @GenericAgentJobs = qw{};

    # get existing generic agent jobs..
    my %JobList = $Kernel::OM->Get('Kernel::System::GenericAgent')->JobList();

    my $DefFilePath =
        $Self->{ConfigObject}->Get('Home')
      . '/var/packagesetup/InitialSetup/'
      . $Self->{PackagePrefix}
      . '_GenericAgents.yml';

    my $GAConfFileContent = $Self->{MainObject}->FileRead(
        Location => $DefFilePath,
        Result   => 'SCALAR',
        Mode     => 'binmode',
    );

    if ( !$GAConfFileContent || !$$GAConfFileContent ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Couldn't read file <$DefFilePath> or file is empty.",
        );
        return 0;
    }

    my $GADefinitions = $Self->{YAMLObject}->Load( Data => $$GAConfFileContent );

    # add generic agent job if not exists
    for my $GenericAgentRef ( @{$GADefinitions} ) {

        # replace Names by IDs where required...
        for my $CurrKey ( keys( %{$GenericAgentRef}) ) {

            if( $CurrKey eq 'StateNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::State')->StateLookup( State => $CurrValue ));
                }
                $GenericAgentRef->{StateIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'QueueNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::Queue')->QueueLookup( Queue => $CurrValue ));
                }
                $GenericAgentRef->{QueueIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'ServiceNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::Service')->ServiceLookup( Service => $CurrValue ));
                }
                $GenericAgentRef->{ServiceIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'SLANames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::SLA')->SLALookup( SLA => $CurrValue ));
                }
                $GenericAgentRef->{SLAIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'TypeNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::Type')->TypeLookup( TypeID => $CurrValue ));
                }
                $GenericAgentRef->{TypeIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'PriorityNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::Priority')->PriorityLookup( PriorityID => $CurrValue ));
                }
                $GenericAgentRef->{PriorityIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'LockNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::Lock')->LockLookup( LockID => $CurrValue ));
                }
                $GenericAgentRef->{LockIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'OwnerNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::User')->UserLookup( UserID => $CurrValue ));
                }
                $GenericAgentRef->{OwnerIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'ResponsibleNames' ) {
                my @ValueArr = qw{};
                for my $CurrValue ( @{$GenericAgentRef->{$CurrKey}}  ) {
                    push( @ValueArr, $Kernel::OM->Get('Kernel::System::User')->UserLookup( UserID => $CurrValue ));
                }
                $GenericAgentRef->{ResponsibleIDs} = \@ValueArr;
            }
            elsif( $CurrKey eq 'ValidName' ) {
                $GenericAgentRef->{Valid} = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup( Valid => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewLockName' ) {
                $GenericAgentRef->{NewLockID} = $Kernel::OM->Get('Kernel::System::Lock')->LockLookup( Lock => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewPriorityName' ) {
                $GenericAgentRef->{NewPriorityID} = $Kernel::OM->Get('Kernel::System::Priority')->PriorityLookup( Priority => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewQueueName' ) {
                $GenericAgentRef->{NewQueueID} = $Kernel::OM->Get('Kernel::System::Queue')->QueueLookup( Queue => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewStateName' ) {
                $GenericAgentRef->{NewStateID} = $Kernel::OM->Get('Kernel::System::State')->StateLookup( State => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewServiceName' ) {
                $GenericAgentRef->{NewServiceID} = $Kernel::OM->Get('Kernel::System::Service')->ServiceLookup( Service => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewSLAName' ) {
                $GenericAgentRef->{NewSLAID} = $Kernel::OM->Get('Kernel::System::SLA')->SLALookup( SLA => $GenericAgentRef->{$CurrKey} );
            }
            elsif( $CurrKey eq 'NewTypeName' ) {
                $GenericAgentRef->{NewTypeID} = $Kernel::OM->Get('Kernel::System::Type')->TypeLookup( Type => $GenericAgentRef->{$CurrKey} );
            }
        }

        # create / update GA job...
        if( $JobList{ $GenericAgentRef->{Name}} && !$Param{OverwriteExistingEntities} ) {
            next;
        }
        elsif ( $JobList{ $GenericAgentRef->{Name}} ) {
            $Kernel::OM->Get('Kernel::System::GenericAgent')->JobDelete(
              Name   => $GenericAgentRef->{Name},
              UserID => 1,
            );
        }

        $Kernel::OM->Get('Kernel::System::GenericAgent')->JobAdd(
            Name   => $GenericAgentRef->{Name},
            Data   => $GenericAgentRef,
            UserID => 1,
        );
    }
    return 1;
}

sub _UpdateSysConfig {
    my ( $Self, %Param ) = @_;

    my @DynamicFields = $Self->_GetDynamicFieldsDefinition();

    # AgentFrontend...
    my $SCCurrentValue = $Kernel::OM->Get('Kernel::Config')->Get(
        'Ticket::Frontend::AgentTicketZoom'
    );

    for my $CurrDF ( @DynamicFields ) {
        next if( !$CurrDF);
        next if( ref($CurrDF) ne 'HASH');
        next if( ! $CurrDF->{'ProcessWidgetDFGroup'} );
        my $CurrDFGroup = $CurrDF->{'ProcessWidgetDFGroup'} || '';

        # update Ticket::Frontend::AgentTicketZoom###ProcessWidgetDynamicFieldGroups...
        my $CurrStrg = $SCCurrentValue->{ProcessWidgetDynamicFieldGroups}->{ $CurrDFGroup } || '';
        my @CurrDF = split( /,\s*/, $CurrStrg);
        my %CurrDFHash = map { $_ => 1 } @CurrDF;
        $CurrDFHash{ $CurrDF->{Name} } = '1';
        $CurrStrg = join( ',', keys(%CurrDFHash) );
        $SCCurrentValue->{ProcessWidgetDynamicFieldGroups}->{ $CurrDFGroup } = $CurrStrg;

        # update Ticket::Frontend::AgentTicketZoom###ProcessWidgetDynamicField...
        $SCCurrentValue->{ProcessWidgetDynamicField}->{ $CurrDF->{Name} } = '1';

    }

    $Kernel::OM->Get('Kernel::Config')->Set(
        Key   => 'Ticket::Frontend::AgentTicketZoom',
        Value => $SCCurrentValue,
    );

    $Kernel::OM->Get('Kernel::System::SysConfig')->ConfigItemUpdate(
        Valid        => 1,
        Key          => 'Ticket::Frontend::AgentTicketZoom',
        Value        => $SCCurrentValue,
        NoValidation => 1,
    );

    # Ticket::Frontend::OverviewSmall...
    my $SCCurrentValueOVS = $Kernel::OM->Get('Kernel::Config')->Get(
        'Ticket::Frontend::OverviewSmall'
    );
    for my $CurrDF ( @DynamicFields ) {
        next if( !$CurrDF);
        next if( ref($CurrDF) ne 'HASH');
        next if( ! $CurrDF->{'OverviewSmall'} );

        # update Ticket::Frontend::OverviewSmall###DynamicField...
        $SCCurrentValueOVS->{'DynamicField'}->{ $CurrDF->{Name} } = '1';

    }

    $Kernel::OM->Get('Kernel::Config')->Set(
        Key   => 'Ticket::Frontend::OverviewSmall',
        Value => $SCCurrentValueOVS,
    );

    $Kernel::OM->Get('Kernel::System::SysConfig')->ConfigItemUpdate(
        Valid        => 1,
        Key          => 'Ticket::Frontend::OverviewSmall',
        Value        => $SCCurrentValueOVS,
        NoValidation => 1,
    );


    # CustomerFrontend...
    my $SCCurrentValueCF = $Kernel::OM->Get('Kernel::Config')->Get(
        'Ticket::Frontend::CustomerTicketZoom'
    );
    for my $CurrDF ( @DynamicFields ) {
        next if( !$CurrDF);
        next if( ref($CurrDF) ne 'HASH');
        next if( ! $CurrDF->{'CustomerTicketZoom'} );

        # update Ticket::Frontend::CustomerTicketZoom###DynamicField...
        $SCCurrentValueCF->{'DynamicField'}->{ $CurrDF->{Name} } = '1';

    }

    $Kernel::OM->Get('Kernel::Config')->Set(
        Key   => 'Ticket::Frontend::CustomerTicketZoom',
        Value => $SCCurrentValueCF,
    );

    $Kernel::OM->Get('Kernel::System::SysConfig')->ConfigItemUpdate(
        Valid        => 1,
        Key          => 'Ticket::Frontend::CustomerTicketZoom',
        Value        => $SCCurrentValueCF,
        NoValidation => 1,
    );

    return 1;
}

sub _AddProcessDefinitions {
    my ( $Self, %Param ) = @_;

    my $DefFilePath = $Self->{ConfigObject}->Get('Home')
        . '/var/packagesetup/InitialSetup/';

    if ( -e $DefFilePath ) {
        my @Files = $Self->{MainObject}->DirectoryRead(
            Directory => $DefFilePath,
            Filter    => $Self->{PackagePrefix}.'_Process*.yml',
        );

        for my $File ( sort(@Files) ) {

            my $YAMLContent = $Self->{MainObject}->FileRead(
                Location => $File,
                Result   => 'SCALAR',
                Mode     => 'utf8',
            );
            next if (!$YAMLContent || !$$YAMLContent);

            my %ProcessImport = $Self->{ProcessObject}->ProcessImport(
                Content                   => $$YAMLContent,
                OverwriteExistingEntities => $Param{OverwriteExistingEntities} || '1',
                UserID                    => 1,
            );

            if ( !$ProcessImport{Success} ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => 'Process import error: ' . $ProcessImport{Message},
                );
            }
            else {
              $Self->{LogObject}->Log(
                  Priority => 'notice',
                  Message  => 'Process import: ' . $ProcessImport{Message},
              );            }

        }
    }
    return 1;
}

sub _AddACLsFromFile {
    my ( $Self, %Param ) = @_;

    my $ReplaceACL =
      $Self->{ConfigObject}->Get( 'ACLImport::ReplaceAvailableACLs' ) || '1';

    my $DefFilePath =
        $Self->{ConfigObject}->Get('Home')
      . '/var/packagesetup/InitialSetup/'
      . $Self->{PackagePrefix}
      . '_ACLConfiguration.yml';

    my $ACLConfFileContent = $Self->{MainObject}->FileRead(
        Location => $DefFilePath,
        Result   => 'SCALAR',
        Mode     => 'binmode',
    );

    if ( !$ACLConfFileContent || !$$ACLConfFileContent ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Couldn't read file <$DefFilePath> or file is empty.",
        );
        return 0;
    }

    my $ACLDefinitions = $Self->{YAMLObject}->Load( Data => $$ACLConfFileContent );

    if ( ref $ACLDefinitions ne 'ARRAY' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Couldn't load content of file <$DefFilePath>.",
        );
    }

    my @UpdatedACLs;
    my @AddedACLs;
    my @ACLErrors;

    ACLCONFIG:
    for my $ACL ( @{$ACLDefinitions} ) {
        next ACLCONFIG if !$ACL;
        next ACLCONFIG if ref $ACL ne 'HASH';
        my @AvailableACLs = @{
            $Kernel::OM->Get('Kernel::System::ACL::DB::ACL')->ACLListGet(
                UserID => 1
              )
              || []
        };
        @AvailableACLs = grep { $_->{Name} eq $ACL->{Name} } @AvailableACLs;
        if ( $ReplaceACL && $AvailableACLs[0] ) {
            my $Success =
              $Kernel::OM->Get('Kernel::System::ACL::DB::ACL')->ACLUpdate(
                %{ $AvailableACLs[0] },
                Name           => $ACL->{Name},
                Comment        => $ACL->{Comment},
                Description    => $ACL->{Description} || '',
                StopAfterMatch => $ACL->{StopAfterMatch} || 0,
                ConfigMatch    => $ACL->{ConfigMatch} || undef,
                ConfigChange   => $ACL->{ConfigChange} || undef,
                ValidID        => $ACL->{ValidID} || 1,
                UserID         => 1,
              );
            if ($Success) {
                push @UpdatedACLs, $ACL->{Name};
            }
            else {
                push @ACLErrors, $ACL->{Name};
            }
        }
        else {
            # now add the ACL
            my $Success =
              $Kernel::OM->Get('Kernel::System::ACL::DB::ACL')->ACLAdd(
                Name           => $ACL->{Name},
                Comment        => $ACL->{Comment},
                Description    => $ACL->{Description} || '',
                ConfigMatch    => $ACL->{ConfigMatch} || undef,
                ConfigChange   => $ACL->{ConfigChange} || undef,
                StopAfterMatch => $ACL->{StopAfterMatch},
                ValidID        => $ACL->{ValidID} || 1,
                UserID         => 1,
              );
            if ($Success) {
                push @AddedACLs, $ACL->{Name};
            }
            else {
                push @ACLErrors, $ACL->{Name};
            }
        }
    }

    # log results of ACL import...
    my $UpdatedACLsStrg = join( ', ', @UpdatedACLs ) || '';
    my $AddedACLsStrg   = join( ', ', @AddedACLs )   || '';
    my $ACLErrorsStrg   = join( ', ', @ACLErrors )   || '';
    if ($AddedACLsStrg) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => 'New ACLs: ' . $AddedACLsStrg
        );
    }
    if ($UpdatedACLsStrg) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => 'Updated ACLs: ' . $UpdatedACLsStrg,
        );
    }
    if ($ACLErrorsStrg) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'ACLs import error: ' . $ACLErrorsStrg,
        );
    }

    #---------------------------------------------------------------------------
    # enable ACLs...
    my $ZZZACLPath =
      $Self->{ConfigObject}->Get('Home') . '/Kernel/Config/Files/ZZZACL.pm';
    my $ACLDump = $Kernel::OM->Get('Kernel::System::ACL::DB::ACL')->ACLDump(
        ResultType => 'FILE',
        Location   => $ZZZACLPath,
        UserID     => 1,
    );
    if ($ACLDump) {
        my $Success =
          $Kernel::OM->Get('Kernel::System::ACL::DB::ACL')->ACLsNeedSyncReset();
        if ($Success) {
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => 'All ACLs activated!',
            );
        }
        else {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'ACLs activation error!',
            );
        }
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'ACLs activation error - '
              . 'could not create file ZZZACL.pm!',
        );
    }
    return 1;
}

sub _ImportQueuesGroupsRoles {
    my ( $Self, %Param ) = @_;

    my $DefFilePath =
        $Self->{ConfigObject}->Get('Home')
      . '/var/packagesetup/InitialSetup/'
      . $Self->{PackagePrefix}. '_QGR.csv';

    my $QGRFileContentRef = $Self->{MainObject}->FileRead(
        Location => $DefFilePath,
        Result   => 'SCALAR',
        Mode     => 'binmode',
    );
    if ( !$QGRFileContentRef || !$$QGRFileContentRef ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Couldn't read file <$DefFilePath> or file is empty.",
        );
        return 0;
    }
    my @RawContent = split( /\n/, $$QGRFileContentRef);

    my @Content = qw{};
    my $Line=1;
    for my $CurrLine ( @RawContent ) {
        utf8::decode ($CurrLine);
        push( @Content, $CurrLine );
    }

    my $Result = $Kernel::OM->Get('Kernel::System::QueuesGroupsRoles')->Upload(
        MessageToSTDERR => 1,
        Content         => \@Content,
    );

    return 1;
}

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;
    my $ValidID = $Self->{ValidObject}->ValidLookup( Valid => 'valid', );

    # get all current dynamic fields
    my $DynamicFieldList = $Self->{DynamicFieldObject}->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }

    # get the last element from the order list and add 1
    my $NextOrderNumber = 1;
    if (@DynamicfieldOrderList) {
        $NextOrderNumber = $DynamicfieldOrderList[-1] + 1;
    }

    # get the definition for all dynamic fields for ITSM
    my @DynamicFields = $Self->_GetDynamicFieldsDefinition();

    # create a dynamic fields lookup table
    my %DynamicFieldLookup;
    for my $DynamicField ( @{$DynamicFieldList} ) {
        next if ref $DynamicField ne 'HASH';
        $DynamicFieldLookup{ $DynamicField->{Name} } = $DynamicField;
    }

    # get current post master x-headers
    my %PostMasterHeaders =
      map { $_ => 1 } @{ $Self->{ConfigObject}->Get('PostmasterX-Header') };
    my @PostMasterValuesToSet;


    # create or update dynamic fields
    DYNAMICFIELD:
    for my $DynamicField (@DynamicFields) {
        my $CreateDynamicField;

        # check if the dynamic field already exists
        if ( ref $DynamicFieldLookup{ $DynamicField->{Name} } ne 'HASH' ) {
            $CreateDynamicField = 1;
        }
        else {
            my $Success = $Self->{DynamicFieldObject}->DynamicFieldUpdate(
                %{$DynamicField},
                ID => $DynamicFieldLookup{ $DynamicField->{Name} }->{ID},
                FieldOrder => $DynamicFieldLookup{ $DynamicField->{Name} }->{FieldOrder},
                Config     => $DynamicField->{Config},
                ValidID => $ValidID,
                Reorder => 0,
                UserID  => 1,
            );
        }

        # check if new field has to be created
        if ($CreateDynamicField) {
            my $FieldID = $Self->{DynamicFieldObject}->DynamicFieldAdd(
                Name       => $DynamicField->{Name},
                Label      => $DynamicField->{Label},
                FieldOrder => $NextOrderNumber,
                FieldType  => $DynamicField->{FieldType},
                ObjectType => $DynamicField->{ObjectType},
                Config     => $DynamicField->{Config},
                ValidID    => $ValidID,
                UserID     => 1,
            );
            next DYNAMICFIELD if !$FieldID;
            $NextOrderNumber++;
        }

        # check if x-header for the dynamic field already exists
        if ( !$PostMasterHeaders{ 'X-OTRS-DynamicField-'. $DynamicField->{Name} } ) {
            $PostMasterHeaders{ 'X-OTRS-DynamicField-' . $DynamicField->{Name} } = 1;
        }
        if ( !$PostMasterHeaders{ 'X-OTRS-FollowUp-DynamicField-'. $DynamicField->{Name} } ) {
            $PostMasterHeaders{ 'X-OTRS-FollowUp-DynamicField-'
                  . $DynamicField->{Name} } = 1;
        }
    }


    # revert values from hash into an array
    @PostMasterValuesToSet = sort keys %PostMasterHeaders;

    # execute the update action in sysconfig
    my $Success = $Self->{SysConfigObject}->ConfigItemUpdate(
        Valid => 1,
        Key   => 'PostmasterX-Header',
        Value => \@PostMasterValuesToSet,
    );
    return 1;
}

sub _NotificationImport {
    my ( $Self, %Param ) = @_;

    my $DefFilePath = $Self->{ConfigObject}->Get('Home')
        . '/var/packagesetup/InitialSetup/';

    if ( -e $DefFilePath ) {
        my @Files = $Self->{MainObject}->DirectoryRead(
            Directory => $DefFilePath,
            Filter    => $Self->{PackagePrefix}.'_*Notification*.yml',
        );

        for my $File (sort(@Files)) {

            my $YAMLContent = $Self->{MainObject}->FileRead(
                Location => $File,
                Result   => 'SCALAR',
                Mode     => 'utf8',
            );

            my $NotificationImport = $Self->{NotificationObject}->NotificationImport(
                Content                        => $$YAMLContent,
                OverwriteExistingNotifications => 1,
                UserID                         => 1,
            );

            if ( !$NotificationImport->{Success} ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => 'Notification import error: '
                    . $NotificationImport->{Message}
                    . "("
                    . $NotificationImport->{NotificationErrors}
                    . ")",
                );
                return 0;
            }
            else {
              return 1;
            }
        }
    }
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
