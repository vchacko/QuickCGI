package OrderBy;

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
use DBI;
use QuickCGI::DBTree;
use strict;
            
# The new operator definition
sub new{
        my $class = shift;
        my $this ={};
        $this->{FIXED} = new Gtk::Fixed();
        bless($this,$class);
        return $this;
}
            
sub get_page{
        return $_[0]->{FIXED};
}
            
# Initialize the object
sub Initialize{
	my($this) = shift;
        my $fixed = $this->{FIXED};
            
        my $db_table_window = new Gtk::ScrolledWindow( undef, undef );
        $db_table_window->set_usize( 200, 205 );
        my $lbltable = new Gtk::Label("Fields in Database");
        my $lblreport = new Gtk::Label("Order By");
        $fixed->put($lbltable,50,23);
        $fixed->put($lblreport,400,23);
        $fixed->put($db_table_window,15,43);
            
        my $tree = new DBTree($this->{REPORT}->get_connection(),$this->{REPORT}->get_database());
            
        $db_table_window->add_with_viewport($tree);
        $db_table_window->show();
	
	my $add = new Gtk::Button("Add ->");
        my $remove = new Gtk::Button("<- Remove");
        $add->set_usize( 100, 25 );
        $remove->set_usize( 100, 25 );
        $fixed->put($add,225,63);
        $fixed->put($remove,225,143);
        my $rep_table_window = new Gtk::ScrolledWindow( undef, undef );

        my $report_list = new Gtk::List();
        $rep_table_window->add_with_viewport($report_list);
	$rep_table_window->set_usize( 200, 175 );
        $fixed->put($rep_table_window,335,43);

	my $lblorder = new Gtk::Label("Order");
	$fixed->put($lblorder,260,225);
	my $order = new Gtk::Combo();
	$order->set_popdown_strings(("Ascending", "Descending"));
	$order->set_usize(200,23);
	$fixed->put($order,335,225);

	$this->{DB} = $tree;
        $this->{LIST} = $report_list;

        $add->signal_connect( 'clicked', \&add_field, $this);
        $remove->signal_connect( 'clicked', \&remove_field, $this);
	$order->entry->signal_connect('changed',\&change_order,$this);


	$fixed->show_all();
}
sub change_order{
	my ($entry,$this) = @_;
	my $order = $entry->get_text();
	if($order eq 'Ascending'){
		$order = 'ASC';
	}else{
		$order = 'DESC';
	}
	
	$this->{REPORT}->change_orderby($order,$this->{LIST}->child_position( $this->{LIST}->selection() ) );
	
	
}
sub set_report{
            
        my($this) = shift;
        $this->{REPORT} = shift;
        $this->Initialize();
}

sub remove_field{
            
        my ( $remove, $this ) = @_;
        my $report_list = $this->{LIST};
        my $item = $report_list->selection();
        if( $item ){
                my $lbl = $item->children();
                $this->{REPORT}->delete_orderby( $report_list->child_position( $item ) );
                $report_list->remove( $item );
        }
}
            
sub add_field{
            
        my ($add,$this) = @_;
            
        my $tree = $this->{DB};
        my $report_list = $this->{LIST};
        my $item =  $tree->selection();
        unless($item->subtree()){
            
                my $field = $item->get_user_data();
                my @colums = split/\./,$field;
                my $new_item = new_with_label Gtk::ListItem($colums[$#colums]);
            
                $new_item->show();
                $report_list->add( $new_item );
                $this->{REPORT}->insert_orderby( $field, "ASC");

        }
}
sub next_pressed{
	return 1;
}

1;
