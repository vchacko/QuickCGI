package DBTree;
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

@DBTree::ISA = qw(Gtk::Tree);
sub new{
        my ($class,$dbh,$dbname) = @_;
        my $this = new Gtk::Tree();
        bless($this,$class);

############################
	my $leaf = new_with_label Gtk::TreeItem( $dbname);
        my $subtree = new Gtk::Tree();
            
        $this->append( $leaf );
        $leaf->signal_connect( 'expand', \&expand_db, $dbh,$subtree);
        $leaf->signal_connect( 'collapse',\&collapse_tree,$dbh);
        $leaf->set_user_data( $dbname);
        $leaf->show();
            
        $leaf->set_subtree($subtree);

###########################
        return $this;
}


sub expand_db{
            
        my ($leaf,$dbh,$subtree) = @_;
        my $selected = '';
        my @db_info  = $dbh->tables('','','');
        my $child;
        my $item_new;
        foreach my $tables(@db_info){
            
                if($tables =~ /\./){
                        $child = new Gtk::Tree();
                        $tables =~ s/`//g;
                        my @schema = split/\./,$tables;
                        if($selected !~ $schema[0]){
                                $item_new = new_with_label Gtk::TreeItem($schema[0]);
                                $item_new->set_user_data( $schema[0] );
                                $item_new->signal_connect( 'expand',\&expand_schema,$child,$dbh);
                                $item_new->signal_connect( 'collapse', \&collapse_tree,$dbh,'schema');
            
                                $subtree->append($item_new);
                                $item_new->set_subtree($child);
                                $selected = $selected.":".$schema[0];
                                $item_new->show();
                        }
                }
                else{
                        $child = new Gtk::Tree();
                        $tables =~ s/`//g;
                        $item_new = new_with_label Gtk::TreeItem($tables);
                        $item_new->set_user_data( $tables );
                        $item_new->signal_connect( 'expand',\&expand_table,$child,$dbh);
                        $item_new->signal_connect( 'collapse', \&collapse_tree,$dbh,'table');
            
                        $subtree->append($item_new);
                        $item_new->set_subtree($child);
                        $item_new->show();
                }
        }
            
}
            
sub collapse_tree{
        my ( $item,$dbh,$type) = @_;
            
        my $subtree = new Gtk::Tree();
            
        $item->remove_subtree();
        $item->set_subtree( $subtree );
            
        if($type){
            
                if($type eq 'schema'){
            
                        $item->signal_connect( 'expand', \&expand_schema, $subtree,$dbh);
            
                }elsif($type eq 'table'){
            
                        $item->signal_connect( 'expand', \&expand_table, $subtree,$dbh);
            
                }
        }else{
            
                $item->signal_connect( 'expand', \&expand_db,$dbh, $subtree );
            
        }
            
}
            
            
sub expand_schema{
        my ( $item,$subtree,$dbh ) = @_;
        my $schema = $item->get_user_data();
            
        my @table_inf  = $dbh->tables('',$schema,'');
        my $child;
        my @temp;
        foreach my $table(@table_inf ){
            
                @temp = split/\./,$table;
                my $item_new = new_with_label Gtk::TreeItem($temp[1]);
                $subtree->append($item_new);
                $child = new Gtk::Tree();
                $item_new->set_subtree($child);
                $item_new->set_user_data($table);
                $item_new->signal_connect( 'expand',\&expand_table,$child,$dbh);
                $item_new->signal_connect( 'collapse', \&collapse_tree,$dbh,'table');
            
                $item_new->show();
        }
}
sub expand_table{
        my ( $item,$subtree,$dbh ) = @_;
            
        my $table_name = $item->get_user_data();
            
        my $sql = "select * from $table_name";
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        my $col_array =  $sth->{NAME};
# Returns reference to an array
        foreach my $column(@$col_array){
                my $item_new = new_with_label Gtk::TreeItem($column);
                $subtree->append($item_new);
                $item_new->set_user_data($table_name.".".$column);
                $item_new->show();
        }
}
            
            
1;

