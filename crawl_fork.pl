use strict;
use warnings;
use Mojo::UserAgent;
use feature 'say';
use Carp;
use English qw(-no_match_vars);
use Parallel::ForkManager;

my $pm = new Parallel::ForkManager(35);

print "Enter the name of the output file: ";
my $files = <STDIN>;
chomp($files);

if (-f $files) {
    unlink $files
        or croak "Cannot delete $files: $!";
}

my $OUTFILE;

open $OUTFILE, '>>', $files
    or croak "Cannot open $files: $OS_ERROR";

my $ua = Mojo::UserAgent->new;
my $children;
my $testchild;
my @tocrawl;
my $verdict;
my $testsplice;
my $bettorName;
my $betDate;
my $winLoss;
my $total;
my $whatSport;
my $success;
my $tx;

print "Enter the base URL without the number at the end (ex. http://pregame.com/pregamepros/picks/archive.aspx?id=): ";
my $baseurl = <STDIN>;
chomp($baseurl);

print "Enter the most recent pick_id number that follows the equal sign (ex. 192708): ";
my $starting_number = <STDIN>;
chomp($starting_number);

my $fullURL = $baseurl . $starting_number;

print "How many decrementing iterations do you want to run? ";
my $iterations = <STDIN>;
chomp($iterations);

for(my $i = 0; $i < $iterations; $i++)
{
$tocrawl[$i] = $fullURL;
$starting_number = $starting_number -1;
$fullURL = $baseurl . $starting_number;
}

foreach (@tocrawl) 
{
$pm->start and next;

my $tx = $ua->get($_);
my $testchild = $tx->res->dom->at('.dtPgTop');

if($testchild) {
my $children = $tx->res->dom->at('.dtPgTop')->all_text;
my $children2 = $tx->res->dom->at('.dtPgSub')->all_text;
my $children3 = $tx->res->dom->at('.ddPgMid')->all_text;
my $children4 = $tx->res->dom->at('.emPgDate')->all_text;
$verdict = $children . " " . $children2 . " " . $children3 . " " . $children4;

if ($_ =~ /id\=(.[0-9]*)/)
{
   print { $OUTFILE } $1;
   print { $OUTFILE } ",";
}

if ($verdict =~ /([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9])/)
{
    $betDate = $1;
    print { $OUTFILE } $betDate;
    print { $OUTFILE } ",";
}

if ($verdict =~ /[(PM)|(AM)] (.*) \|/)
{
    $bettorName = $1;
    print { $OUTFILE } $bettorName;
    print { $OUTFILE } ",";
}

if ($verdict =~ /Results: ([WTL]), (\-?\$?[0-9]*)/)
{
    $winLoss = $1;
    print { $OUTFILE } $winLoss;
    print { $OUTFILE } ",";
    $total = $2;
    print { $OUTFILE } $total;
    print { $OUTFILE } ",";
}

if ($children =~ /\| (.*)/)
{
   $whatSport = $1;
   print { $OUTFILE } $whatSport;
   print { $OUTFILE } "\n";
}

}

$pm->finish;

}

close $OUTFILE
    or croak "Cannot close $files: $OS_ERROR";
exit 0;
