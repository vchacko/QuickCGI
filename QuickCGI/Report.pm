package Report;
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

sub new {

	$class = shift;
	$this = {};
	$this->{fields} = {};
	$this->{order} = [];
	$this->{where} = [];
	$this->{orderby} = [];
	$this->{show_table} = 0;
	bless $this,$class;
}

sub set_table_width{
	my ( $this, $size ) = @_;
	$this->{table_width} = $size;
}
sub get_table_width{
	if( $_[0]->{show_table} ){
        	return $_[0]->{table_width}->get_text();
	}
	return 0;
}

sub show_table{
	my ( $this, $show ) = @_;
	if( $show ){
		$this->{show_table} = $show;
	}
	return $this->{show_table};
	
}
sub set_table_font_family{
        my ( $this, $family ) = @_;
        $this->{table_font_family} = $family;
}
sub set_table_font_size{
        my ( $this, $size ) = @_;
        $this->{table_font_size} = $size;
}
sub set_table_font_weight{
        my ( $this, $weight ) = @_;
        $this->{table_font_weight} = $weight;
}
sub set_table_font_style{
        my ( $this, $style ) = @_;
        $this->{table_font_style} = $style;
}
            
sub set_table_color{
        my ( $this, $color ) = @_;
        $this->{table_color} = $color;
}
sub get_table_style{
        my $this = shift;
        my $family = $this->{table_font_family};
        my $size = $this->{table_font_size};
        my $weight = $this->{table_font_weight};
        my $style = $this->{table_font_style};
        my $color = $this->{table_color};
        my $font =' ';
            
        if( $family ){
                $font = $family;
        }
        if( $size ){
                $font = $font.$size;
        }
        if( $weight ){
                $font = $font.$weight;
        }
        if( $style ){
                $font = $font.$style;
        }
        if( $color ){
                $font = $font.$color;
        }
            
        return $font;
}
   
sub set_title_font_family{
	my ( $this, $family ) = @_;
	$this->{title_font_family} = $family;
}
sub set_title_font_size{
        my ( $this, $size ) = @_;
        $this->{title_font_size} = $size;
}
sub set_title_font_weight{
        my ( $this, $weight ) = @_;
        $this->{title_font_weight} = $weight;
}
sub set_title_font_style{
        my ( $this, $style ) = @_;
        $this->{title_font_style} = $style;
}

sub set_title_color{
        my ( $this, $color ) = @_;
        $this->{title_color} = $color;
}

sub get_title_font{
	my $this = shift;
	my $family = $this->{title_font_family};
	my $size = $this->{title_font_size};
	my $weight = $this->{title_font_weight};
	my $style = $this->{title_font_style};
	my $color = $this->{title_color};
	my $font =' ';

	if( $family ){
		$font = $family;
	}
	if( $size ){
                $font = $font.$size;
	}
        if( $weight ){
                $font = $font.$weight;
	}
        if( $style ){
                $font = $font.$style;
	}
	if( $color ){
                $font = $font.$color;
        }

	return $font;
}

sub set_title{
	
	my ( $this, $title ) = @_;
	$this->{title} = $title;
}

sub get_title_entry{
	return $_[0]->{title};
}

sub get_title{
	return $_[0]->{title}->get_text();
}

sub change_orderby{

	my ( $this, $order, $pos ) = @_;
	if( $this->{orderby}->[$pos] !~ $pos ){
		my @temp = split /\ /,$this->{orderby}->[$pos];
		$temp[$#temp] = $order;
		$this->{orderby}->[$pos] = join ' ',@temp;
	}
}
sub insert_orderby{
        my $this = shift;
        my $ref_orderby = $this->{orderby};
        my @orderby = @$ref_orderby;
        $this->{orderby}->[++$#orderby] = $_[0]." ".$_[1];
}
            
sub delete_orderby{
        my $ref_orderby = $_[0]->{orderby};
        my @orderby = @$ref_orderby;
        splice ( @orderby, $_[1], 1 );
	$_[0]->{orderby} = \@orderby;
}

sub swap_order{
	my ( $this, $x, $y ) = @_;
	my $temp = $this->{order}->[$x];
	$this->{order}->[$x] = $this->{order}->[$y];
	$this->{order}->[$y] = $this->{order}->[$x];
}
sub get_sql{

	my $this = shift;
       	my $report_field  = $this->{fields};
       	my $fieldnames = $this->{order};
       	my $where_ref = $this->{where};
	my $orderby_ref = $this->{orderby};
	my @orderby = @$orderby_ref;
       	my @where = @$where_ref;
	my @column_head;
        my @column_names;
        my $column;
        my @tables;
        my @temp;

	foreach my $keys(@$fieldnames){
                $column = $report_field->{$keys}->{value};
                push @column_names,$column;
                my $table = $this->get_table($column,join(',',@tables));
                if($table){
                        push @tables,$table;
                }
        }
            
        foreach my $keys(@where){

                my @fiels = split/=/,$keys;
                foreach my $column(@fiels){
                        my $table = $this->get_table($column,join(',',@tables));
                        if($table && ($table !~ /\'/)){
                                push @tables,$table;
                        }
                }
	}

	my $columns = join ', ',@column_names;

	my $table_names = join ', ',@tables;
	

        my $sql = "SELECT $columns FROM $table_names";

        if(@where){
               $sql =$sql." WHERE ".join ' AND ',@where;
        }
	if(@orderby){
		$sql =$sql." ORDER BY ".join ', ',@orderby;
	}
	return $sql;
}

sub get_heads{
	my $this = shift;
	my $fieldnames = $this->{order};
	my $report_field  = $this->{fields};	
	foreach my $keys(@$fieldnames){
                push @column_head,$report_field->{$keys}->{head};
	}
	return @column_head;
}

sub get_table{
            
        my ($this,$column,$table_names) = @_;
        my @temp = split/\./,$column;
               my $tmp;
            
               if($temp[2]){
                       $tmp = $temp[0].".".$temp[1];
               }else{
                       $tmp = $temp[0];
               }
               if($tmp){
                        $tmp =~s/\s//;
            
                       if($table_names !~ /$tmp/){
                               return $tmp;
                       }
               }
        return 0;
}

sub insert_condition{
	my $this = shift;
	my $ref_where = $this->{where};
        my @where = @$ref_where;
        $this->{where}->[++$#where] = $_[0];
}

sub delete_condition{
	my $ref_where = $_[0]->{where};
        my @where = @$ref_where;
	splice ( @where, $_[1], 1 );
	$_[0]->{where} = \@where;
}

sub add_field{
	my ($this,$field) = @_;
	my @colums = split/\./,$field;
	$this->{fields}->{$colums[$#colums]} = {value => $field,head=>ucfirst $colums[$#colums]};
	$this->set_order($colums[$#colums]);
}

sub remove_field{
        delete $_[0]->{fields}->{$_[1]->get()};
	my $ref_order = $_[0]->{order};
        my @order = @$ref_order;
	splice ( @order, $_[2], 1 );
	print join(", ",@order),"\n";
	$_[0]->{order} = \@order;
}

sub set_order{
	my $ref_order = $_[0]->{order};
	my @order = @$ref_order;
	$_[0]->{order}->[++$#order] = $_[1];
}

sub set_host{
        $_[0]->{host} = $_[1];
}
            
sub set_port{
        $_[0]->{port} = $_[1];
}

sub set_dbms{
	$_[0]->{dbms} = $_[1];
}

sub set_database{
	$_[0]->{database} = $_[1];
}

sub set_user_id{
	 $_[0]->{user_id} = $_[1];
}

sub set_password{
	$_[0]->{password} = $_[1];
}

sub set_connection{
	$_[0]->{connection} = $_[1];
}

sub get_host{
        return $_[0]->{host}->get_text();
}
            
sub get_port{
        return $_[0]->{port}->get_text();
}

sub get_dbms{
        return $_[0]->{dbms}->get_text();
}
            
sub get_database{
        return $_[0]->{database}->get_text();
}
            
sub get_user_id{
        return $_[0]->{user_id}->get_text();
}
            
sub get_password{
        return $_[0]->{password}->get_text();
}

sub get_connection{
        return $_[0]->{connection};
}

1;
