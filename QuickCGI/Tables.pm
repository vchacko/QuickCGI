package Tables;
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
                                                                                         
        my ($this)= @_;
	my $db_table_window = new Gtk::ScrolledWindow( undef, undef );
	my $add = new Gtk::Button("Add ->");
#	my $add_all = new Gtk::Button("Add all >>");
	my $remove = new Gtk::Button("<- Remove");
#	my $remove_all = new Gtk::Button("<< Remove all");
	my $rep_table_window = new Gtk::ScrolledWindow( undef, undef );
	my $lbltable = new Gtk::Label("Fields in Database");	
	my $lblreport = new Gtk::Label("Fields in Report");
	
	$db_table_window->set_usize( 200, 200 );
	$rep_table_window->set_usize( 200, 200 );
	$add->set_usize( 100, 25 );
#	$add_all->set_usize( 100, 25 );
	$remove->set_usize( 100, 25 );
#	$remove_all->set_usize( 100, 25 );

	my $frame = $this->{FIXED};

	$frame->put($add,225,63);
#	$frame->put($add_all,225,103);
	$frame->put($remove,225,143);
#	$frame->put($remove_all,225,183);
	
	my $report_list = new Gtk::List();
	$rep_table_window->add_with_viewport($report_list);
	
	$frame->put($db_table_window,15,43);
	$frame->put($rep_table_window,335,43);
	$frame->put($lbltable,50,23);
	$frame->put($lblreport,370,23);
	$db_table_window->set_policy( 'automatic', 'automatic' );
        $db_table_window->show();

# Create root tree
        my $tree = new DBTree($this->{REPORT}->get_connection(),$this->{REPORT}->get_database());
        $db_table_window->add_with_viewport($tree);
        $tree->set_selection_mode( 'single' );
        $tree->set_view_mode( 'item' );
        $tree->show();

	$this->{DB} = $tree;
	$this->{LIST} = $report_list;

	my $up = new Gtk::Button("Up");
	my $down = new Gtk::Button("Down");
	$up->set_usize( 50, 25 );
	$down->set_usize( 50, 25 );
	$frame->put($up,425,238);
	$frame->put($down,485,238);

	$add->signal_connect( 'clicked', \&add_field, $this);
	$remove->signal_connect( 'clicked', \&remove_field, $this);	
#	$add_all->signal_connect( 'clicked',\&add_all_fields,$this);
	$up->signal_connect( 'clicked',\&move_up,$this);
	$frame->show_all();
}

sub move_up{
	my ( $up, $this ) = @_;
	my $report_list = $this->{LIST};
	my $item1 = $report_list->selection();
#my $index = $report_list->child_position( $item1 );
#if( $item1 ){print $index,"\n";	}
	if( $item1 ){
#		new MessageBox( "Select a record to move" );
#		return 0;
#	}
		my $index = $report_list->child_position( $item1 );

		if ( $index ){
			$report_list->select_item( $index-1 );
			my $item2 = $report_list->selection();
			$report_list->unselect_item( $index-1 );
			my @items = ( $item1, $item2 );
print $index,"\n";	
#	if( $item1 ){
#		remove_field( $up, $this );
#		my @items = ( $item );
#			$report_list->remove_items( @items );
#			$report_list->remove_item( $item2 );
#my ($x, $y);
#$x = $item1->data;
#$y = $item2->data;
#print $x,"\t",$y,"\n";			
			$this->{REPORT}->swap_order( $index, $index-1 );
print join( $",@items), $index-1,"\n";

			$report_list->insert_items( 1,2,2, @items, $index );

		}
	}else{
		new MessageBox( "Select a record to move" );
                return 0;
	}
}

sub remove_field{

	my ( $remove, $this ) = @_;
	my $report_list = $this->{LIST};
	my $item = $report_list->selection();
	if( $item ){
		my $lbl = $item->children();
		$this->{REPORT}->remove_field( $lbl, $report_list->child_position( $item ) );
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
 		$report_list->append_items( ($new_item) );
		$this->{REPORT}->add_field($field);
	}
}

sub add_all_fields{
            
        my ($add,$this) = @_;
            
        my $tree = $this->{REPORT}->{DB};
        my $report_list = $this->{LIST};
        my $report_field  = $this->{REPORT}->{FIELDS};
        my $item =  $tree->selection();
        unless($item->subtree){
            
                my $field = $item->get_user_data();
                my @colums = split/\./,$field;
                my $new_item = new_with_label Gtk::ListItem($colums[$#colums]);
                $new_item->show();
                $report_list->add($new_item );
                $report_field->{$colums[$#colums]} = $field;
        }
}
sub next_pressed{
#	my $this = shift;
#	unless( $this->{LIST}->select_item( 0 )){
#		new MessageBox( "Select atleast one field !" );
#		return 0;
#	}
	return 1;
}

sub get_report{
	return $_[0]->{REPORT};
}
sub set_report{
	
	my $this = shift;
	$this->{REPORT} = shift;
	$this->Initialize();

}
1;

