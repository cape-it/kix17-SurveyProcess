# --
# Copyright (C) 2006-2017 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_SurveyProcess;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Resets the process-assignment of a ticket to a previously set if they were stored in other dynamic fields.'} =
      'Stellt eine ggf. zuvor vorhandene Prozess-/Aktivitätszuordnung wieder her, sofern sie in anderen dynamischen Feldern gespeichert wurden.';
    $Lang->{'This option defines which dynamic field is used to store the current Process Management process entity when assigning the survey process.'} =
      'Definiert welches dynam. Feld zur Zwischenspeicherung der aktuellen Prozesszuordnung genutzt wird.';
    $Lang->{'This option defines which dynamic field is used to store the current Process Management activity entity when assigning the survey process.'} =
      'Definiert welches dynam. Feld zur Zwischenspeicherung der aktuellen Prozessaktivität genutzt wird.';
    $Lang->{'This option defines which status is set in DF CustomerSatisfactionStatus when a ticket is selected for the survey. Value must match a value defined in the dynmic field configuration.'} =
      'Definiert welcher Wert im dynamischen Feld CustomerSatisfactionStatus gesetzt wird, wenn ein Ticket für eine Umfrage ausgewählt wird. Der hinterlegte Wert muss mit der Konfiguration des Feldes übereinstimmen.';
    $Lang->{'This option defines to which probability the ticket is assigned to the survey process. Use only values between 0 and 100.'} =
      'Legt die Wahrscheinlichkeit fest mit der einem Ticket eine Zuriedenheitsumfrage zugeordnet wird. Nur Werte zwischen 0 und 100 werden beachtet.';
    $Lang->{'This option defines how many days the satisfaction survey for a ticket will be possible. The countdown starts when the survey is assigned. The countdown is ended by a generic agent.'} =
      'Legt fest wie viele Tage die Zufriedenheitsumfrage läuft. Die Zeit startet wenn der Umfrageprozesses zugeordnet wird. Das Ende wird mittels Generischem Agent überprüft.';
    $Lang->{'This option defines the process ID which is set to assign the survey process.'} =
      'Legt die ProzessID des Umfrageprozesses fest.';
    $Lang->{'This option defines the activity ID which is set when assigning the survey process.'} =
      'Legt die Startaktivität des Umfrageprozesses fest.';
    $Lang->{'Survey Status'} = 'Umfragestatus';
    $Lang->{'Satisfaction Grade'}  = 'Zufriedenheit Bewertung';
    $Lang->{'Satisfaction Remark'} = 'Zufriedenheit Bemerkung';
    $Lang->{'Survey End Date'} = 'Umfrageende-Datum';
    $Lang->{'01: Survey'} = '01: Umfrage';
    $Lang->{'Customer Satisfaction'} = 'Kundenzufriedenheit';
    $Lang->{'Survey Customer Satisfaction'} = 'Umfrage Kundenzufriedenheit';
    $Lang->{'SurveyProcess'} = 'Kundenzufriedenheitsumfrage';
    $Lang->{'requested'} = 'angefragt';
    $Lang->{'done'} = 'erledigt';
    $Lang->{'canceled'} = 'abgebrochen';

    $Lang->{'1 - very good'} = '1 - sehr gut';
    $Lang->{'2 - good'} = '2 - gut';
    $Lang->{'3 - ok' } = '3 - befriedigend';
    $Lang->{'4 - not so ok'} = '4 - ausreichend';
    $Lang->{'5 - bad'} = '5 - schlecht';

    $Lang->{'Participating in our customer satisfaction survey.'} = 'An unserer Kundenumfrage teilnehmen.';


    return 0;

    # $$STOP$$
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
