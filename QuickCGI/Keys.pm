package Keys;
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
use strict;
            
# The new operator definition
sub new{
        my $class = shift;
        my $this ={};
        $this->{FIXED} = new Gtk::Fixed();
        bless($this,$class);
            
# Initialize the object
        return $this;
}

            
sub get_page{
        my $this = shift;
        return $this->{FIXED};
}

sub next_pressed{
	return 1;
}

sub Initialize{

	my($this) = shift;
	my $fixed = $this->{FIXED};
	
	my $rep_table_window = new Gtk::ScrolledWindow( undef, undef );
 	$rep_table_window->set_usize( 200, 205 );
	my $lbltable = new Gtk::Label("Fields in Database");
        my $lblreport = new Gtk::Label("Condition");
	$fixed->put($lbltable,50,23);
	$fixed->put($lblreport,300,23);
	$fixed->put($rep_table_window,15,43);
	
	my $tree = new DBTree($this->{REPORT}->get_connection(),$this->{REPORT}->get_database());	
	
	$rep_table_window->add_with_viewport($tree);
	$rep_table_window->show();

	my $add_left = new  Gtk::Button(" Add (left) -> ");
        my $add_right = new  Gtk::Button(" Add (right) -> ");
	my $insert = new Gtk::Button(" Insert ");
        my $delete = new Gtk::Button(" Delete ");
	$add_right->set_usize( 100, 25 );
	$add_left->set_usize( 100, 25 );
	$insert->set_usize( 75, 25 );
	$delete->set_usize( 75, 25 );
	$fixed->put($add_left,225,43);
	$fixed->put($add_right,225,78);#163
	
	my $lbl_condition = new Gtk::Label("Condition");
	my $left = new Gtk::Entry();
	my $condition =  new Gtk::Combo();
	my $right = new Gtk::Combo(); 
	$left->set_usize( 200, 25 );
	$right->set_usize( 200, 25 );

	$condition->set_usize( 50, 25 );
			
	$fixed->put($left,335,43);
	$fixed->put($lbl_condition,235,116);
	$fixed->put($condition,300,113);
	$fixed->put($right,335,78);#163
	$fixed->put($insert,365,113);
	$fixed->put($delete,450,113);

	my @cond = ('',' = ',' < ',' <= ',' > ',' >= ',' != ');
	$condition->set_popdown_strings(@cond);
	my $where_list_window = new Gtk::ScrolledWindow( undef, undef );
	$where_list_window->set_usize( 306, 100 );
	$fixed->put($where_list_window,225,148);
	my $where_list = new Gtk::List();
	$where_list_window->add_with_viewport($where_list);	

	$add_left->signal_connect( "clicked", \&add_value,$tree,$left );
	$add_right->signal_connect( "clicked", \&add_value,$tree,$right->entry );
	$add_left->signal_connect( "clicked", \&add_value_list,$this->{REPORT},$left,$right);
	$insert->signal_connect( "clicked", \&insert_condition,$this,$left,$condition,$right,$where_list);
	$delete->signal_connect( "clicked", \&delete_condition,$this,$where_list);

        $fixed->show_all();
}

sub add_value_list{

	my ($add,$report,$left,$right) = @_;
	
	my $dbh = $report->get_connection();
	my $field = $left->get_text();
	my $quote = '';
	my @temp = split/\./,$field;
	my $table = $report->get_table($field," ");
	my $sql = "SELECT DISTINCT $field FROM $table ORDER BY $field ASC";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my @values = "";
	my @row_ary  = $sth->fetchrow_array();
	my $sth2 = $dbh->prepare("SELECT $field FROM $table where $field = '$row_ary[0]'");
	if($sth2->execute()){
		$quote = "'";	
		print "Quote \n"
	}
	else{
		print "No Quote\n";
	}
	while(@row_ary = $sth->fetchrow_array()){
		push @values,"$quote$row_ary[0]$quote";
	}
	$right->set_popdown_strings(@values);
}

sub set_report{

	my($this) = shift;
	$this->{REPORT} = shift;
	$this->Initialize();
}

sub add_value{
	my ($add,$tree,$field )=@_;
	my $item =  $tree->selection();
	$field->set_text($item->get_user_data());
}
sub insert_condition{

	my ($insert,$this,$left,$condition,$right,$where_list) = @_;
	my $l = $left->get_text();
	my $r = $right->entry->get_text();
	my $c = $condition->entry->get_text();
	unless ($l && $r && $c){
		new MessageBox("Required field empty.");
		return 0;
	}
	
	$left->set_text('');
	$right->entry->set_text('');
	$condition->entry->set_text('');

	my $where = $l.$c.$r;
	my $new_item = new_with_label Gtk::ListItem($where);
	$this->{REPORT}->insert_condition($where);

	$where_list->add($new_item);
	$new_item->show();
	$right->set_popdown_strings((""));
}

sub delete_condition{
	my ($delete,$this,$where_list) = @_;
	my $item = $where_list->selection();
	if($item){
		my $index = $where_list->child_position( $item );
		$where_list->remove($item);
		$this->{REPORT}->delete_condition($index);
	}
}
1;
