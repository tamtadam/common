#!/usr/local/bin/perl

#sudo apt-get install libssl-dev
#
# SULLR/IO-Socket-SSL-2.038.tar.gz             : make_test NO one dependency not OK (Net::SSLeay); additionally test harness failed
# TOMO/src/Net-SMTPS-0.04.tar.gz               : make_test NO one dependency not OK (IO::Socket::SSL)
# PECO/Email-Send-SMTP-Gmail-1.01.tar.gz       : make_test NO one dependency not OK (Net::SMTPS); additionally test harness failed
#

use strict;
   use warnings;
   use Email::Send::SMTP::Gmail;

   my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com',
                                           -login=>'gherkin.editor',
                                           -pass=>'petiadam2016',
                                           -layer=>'ssl',
                                           -port=>465);

   $mail->send(-to=>'trenyik.adam@gmail.com',
               -subject=>'Mail w/attachment test',
               -verbose=>'1',
               -body=>'Test',);

   $mail->bye;
   

=pod
use strict;
use warnings;
use strict;
use MIME::Lite;
use LWP::Simple;
use Cwd;

our @ISA    = qw/Exporter/;
our @EXPORT = qw/sendmail notify_dev_error/;

my $smtp_server = 'mail.mementorium.hu'; # NSN SMTP server

my $mail_sender = 'postmaster@mementorium.hu'; # a küldö :D

my @emailAddresses = qw / trenyik.adam@gmail.com /; # a cimzettekk
                     
my %args = ( mailto => \@emailAddresses); 

sendmail(\%args);

sub sendmail {
	my ($args) = @_;
	my $user = 'postmaster@mementorium.hu' ;
	my $pass = 'QAWSedrf' ;

	my $msg = MIME::Lite->new(    
							   From    => $mail_sender,
							   To      => join(", ", @{$args->{mailto}}),
							   Subject => "time_to_go_home",
							   Type    => 'text/html',
							   Data    => "Hi Guys, its time to say good bye. Have a nice weekend :D",
	);
	print $msg . "\n";
    print "ASFASDF\n";
	MIME::Lite->send('smtp', $smtp_server, AuthUser=>$user, AuthPass=>$pass, Port => 2525, Timeout => 60);
	print "Sent\n";
	if (not $msg->send) {
		sleep 10;
		print "TRY\n";
		$msg->send;
	}
}