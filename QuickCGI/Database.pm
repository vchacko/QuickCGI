package Database;

#####################################################################################
#	CopyRight (C) 2005 Varghese Chacko, vctheguru@gmail.com						    #
#																					#
#    This file is part of QuickCGI.													#
#																					#
#    QuickCGI is free software: you can redistribute it and/or modify				#
#    it under the terms of the GNU General Public License as published by			#
#    the Free Software Foundation, either version 3 of the License, or				#
#    (at your option) any later version.											#
#																					#
#    QuickCGI is distributed in the hope that it will be useful,					#
#    but WITHOUT ANY WARRANTY; without even the implied warranty of					#
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the					#
#    GNU General Public License for more details.									#
#																					#
#    You should have received a copy of the GNU General Public License				#
#    along with QuickCGI.  If not, see <http://www.gnu.org/licenses/>.				#
#																					#
##################################################################################### 

use Gtk '-init';
use QuickCGI::MessageBox;
use DBI;

use strict;

# The new operator definition
sub new{
	my $class = shift;
	my $this ={};
	$this->{REPORT} = shift;
	$this->{FIXED} = new Gtk::Fixed();
	$this->{FIXED}->set_usize( 560, 280 );
	bless($this,$class);

# Initialize the object
	$this->Initialize();
	return $this;
}
sub get_page{
	my $this = shift;
	return $this->{FIXED};
}
sub Initialize{

	my ($this,$dbh)= @_;

	my $frame = $this->{FIXED};
	my $lbl_dbms = new Gtk::Label( "DBMS" );
	my $lbl_database = new Gtk::Label( "Database" );
	my $lbl_username = new Gtk::Label( "User name" );
	my $lbl_password = new Gtk::Label( "Password" );
	my $lbl_host = new Gtk::Label( "Host Name" );
	my $lbl_port = new Gtk::Label( "Port" );
	
	my $host = new Gtk::Entry();
	my $port = new Gtk::Entry();
	my $dbms = new Gtk::Combo();
	my $database = new Gtk::Combo();
	
	my $username = new Gtk::Entry();
	my $password = new Gtk::Entry();
	
	$host->set_usize( 250, 25 );
	$port->set_usize( 250, 25 );
	$dbms->set_usize( 250, 25 );
	$database->set_usize( 250, 25 );
	$username->set_usize( 252, 25 );
	$password->set_usize( 252, 25 );
	
	$frame->put( $lbl_host, 15, 23 );
	$frame->put( $lbl_port, 15, 58 );
	$frame->put( $lbl_dbms, 15, 93 );
	$frame->put( $lbl_database, 15, 128);
	$frame->put( $lbl_username, 15, 163);
	$frame->put( $lbl_password, 15, 198);

	$frame->put( $host, 85, 20 );
	$frame->put( $port, 85, 55 );
	$frame->put( $dbms, 85, 90 );
        $frame->put( $database, 85, 125 );
        $frame->put( $username, 85, 160 );
        $frame->put( $password, 85, 195 );

	$dbms->entry->signal_connect('focus_out_event',\&show_dsn,$database);
	my $report = $this->{REPORT};
	
#	$this->{host} = $host;
#	$this->{port} = $port;
#	$this->{dbms} = $DBMS->entry;
#	$this->{database} = $database->entry;
#	$this->{username} = $username;
#	$this->{password} = $password;
        $report->set_host( $host );
        $report->set_port( $port );
        $report->set_dbms( $dbms->entry );
        $report->set_database( $database->entry );
        $report->set_user_id( $username );
        $report->set_password( $password );


# Get list of all available drivers via DBI

	my @drivers = DBI->available_drivers();
	$dbms->set_popdown_strings( @drivers );
	$dbms->entry->set_text( "" );

# Set the character in entry as *
	$password->set_visibility( 0 );

}

sub next_pressed{
	
	my $this = shift;
	my $report = $this->{REPORT};
	my $temp = join $", DBI->available_drivers();

	unless( $temp =~ $report->get_dbms() ){
		new MessageBox( "Given DBMS not available !" );
		return 0;
	}

	unless( $report->get_database() ){
		new MessageBox( "Please enter the database name !" );
		return 0;
	}

	my $dsn = "DBI:".$report->get_dbms().":".$report->get_database();

	if( $report->get_host() ){

		$dsn = $dsn.";host=".$report->get_host();

	}
	if( $report->get_port() ){

		$dsn = $dsn.";port=".$report->get_port();

	}

	my $dbh = DBI->connect( $dsn, $report->get_user_id(), $report->get_password(), {PrintError=>0} ) or 
										new MessageBox( "Couldn't connect" );
	$report->set_connection( $dbh );
}

sub show_dsn{

	my ( $dbms, $database )  = @_;

# Get selected DBMS name
	my $driver = $dbms->get_text();
	my $temp = join $", DBI->available_drivers();

	unless( $driver && $temp =~ $driver ){
                new MessageBox( "Driver not available" );
		return 0;
        }

# Get list of all databases in that DBMS
	my @ds =  DBI->data_sources( $driver );	
	my @data_source;
	my $i = 0;

	foreach my $dbn( @ds ){

		my @temp = split/:/, $dbn;
		$data_source[$i] = $temp[2];
		$i++;
	}

	$database->set_popdown_strings( @data_source ) if ( @data_source );
}

1;
