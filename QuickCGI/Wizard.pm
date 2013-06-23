package Wizard;

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
use QuickCGI::Database;
use QuickCGI::Tables;
use QuickCGI::PrintReport;
use QuickCGI::Report;
use QuickCGI::Keys;
use QuickCGI::OrderBy;
use strict;

my $false = 0;
my $true = 1;

# New object via "new" operator
sub new{
        
        my $class = shift;
        my $this = {};
	$this->{REPORT} = new Report();
	$this->{PAGE} = 1;
        bless($this,$class);
        return $this;
}

sub show{

	my $this = shift;
# Create the window
	my $window = new Gtk::Window( "toplevel");
	$window->set_title("QuickCGI - More casual way to write CGI scripts." );
	$window->signal_connect( "delete_event", sub { Gtk->exit( 0 ); } );
	$window->border_width( 20 );
	$window->set_usize( 600, 360 );
	$window->set_policy( 0, 0, 1 );
	$window->set_position( 'center' );

	my $table = new Gtk::Table( 4, 6, $false );
	$window->add( $table );
    
# Create a new notebook, place the position of the tabs
	my $notebook = new Gtk::Notebook();
	$notebook->set_tab_pos( 'top' );
	$table->attach_defaults( $notebook, 0, 6, 0, 1 );
	$notebook->show();

# Create a new screen to select database and add to notebook
	my $label = new Gtk::Label(" Database ");
	my $pages = {};
	$pages->{1} = new Database($this->{REPORT});
	$notebook->append_page($pages->{1}->get_page(), $label);

	$label = new Gtk::Label(" Tables ");
	$pages->{2} = new Tables($this->{REPORT});
	$notebook->append_page($pages->{2}->get_page(), $label);

	$label = new Gtk::Label(" Keys ");
        $pages->{3} = new Keys();
        $notebook->append_page($pages->{3}->get_page(), $label);

	$label = new Gtk::Label(" Value ");
        $pages->{4} = new OrderBy();
        $notebook->append_page($pages->{4}->get_page(), $label);

	$label = new Gtk::Label(" Report ");
        $pages->{5} = new PrintReport($this->{REPORT});
        $notebook->append_page($pages->{5}->get_page(), $label);

	$notebook->set_show_tabs(0);


# Add required buttons
	my $button = new Gtk::Button( "Next >>" );
	$button->signal_connect( "clicked", \&next_pressed,$this,$notebook,$pages);
	$table->attach_defaults( $button, 5, 6, 1, 3);
	$button = new Gtk::Button( "<< Back" );
	$button->signal_connect( "clicked", \&prev_pressed,$this,$notebook,$pages );
	$table->attach_defaults( $button, 4, 5, 1, 3);

	$window->show_all();
        Gtk->main();
        exit(0);
}

sub next_pressed{

	my ($button,$this,$notebook,$pages) = @_;
	unless($pages->{$this->{PAGE}}->next_pressed()){
		return 0;
	}
	$this->{PAGE}++;
	$pages->{$this->{PAGE}}->set_report($this->{REPORT});
	$notebook->next_page();

}

sub prev_pressed{
        
        my ($button,$this,$notebook,$pages) = @_;
        $this->{PAGE}--;
        $notebook->prev_page();
        
}


sub get_report{
	return $_[0]->{REPORT};
}
1;
