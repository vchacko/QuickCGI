package PrintReport;
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
use QuickCGI::StyleDialog;
use Gtk '-init';
use DBI;
use strict;

sub new{
        my $class = shift;
        my $this ={};
        $this->{FIXED} = new Gtk::Fixed();
        bless($this,$class);
        return $this;
}

sub get_page{
        my $this = shift;
        return $this->{FIXED};
}


sub next_pressed{
}

sub set_report{
            
        my $this = shift;
        $this->{REPORT} = shift;
	my $frame = $this->{FIXED};

	my $lbltitle = new Gtk::Label( "Title :" );
	my $title = new Gtk::Entry();
	my $title_font = new Gtk::Button( " Font " );
	my $title_color = new Gtk::Button( " Color " );

	$frame->put( $lbltitle, 13, 13 );
	$title->set_usize( 200, 23 );
	$frame->put( $title, 55, 10 );
	$title_font->set_usize( 50, 25 );
	$frame->put( $title_font, 260, 10);
	$title_color->set_usize( 50, 25 );
	$frame->put( $title_color, 320, 10);
	$this->{REPORT}->set_title($title);

	my $generate = new Gtk::Button( " Generate " );
	$frame->put( $generate, 450, 240 );
	
        $generate->signal_connect( 'clicked', \&create_report, $this );
	
	$title_font->signal_connect( 'clicked', \&change_title_font, $this );
	$title_color->signal_connect( 'clicked', \&change_title_color, $this );
	
	my $lbl_table = new Gtk::Label ( "Table :" );
	$frame->put( $lbl_table, 13, 61 );
	my $border = new Gtk::CheckButton( "Show border" );
	$frame->put( $border, 55, 57 );

	my $lbl_size = new Gtk::Label ( " Width " );
	$frame->put( $lbl_size, 155, 61 );
	my $size = new Gtk::Entry();
	$size->set_usize( 38, 23 );
	$frame->put( $size, 200, 57 );
	$size->set_editable(0);

	my $table_font = new Gtk::Button( " Report Font " );
        my $table_color = new Gtk::Button( " Font Color " );
            
        $table_font->set_usize( 70, 25 );
        $frame->put( $table_font, 13, 97);
        $table_color->set_usize( 70, 25 );
        $frame->put( $table_color, 93, 97);
	$this->{REPORT}->set_table_width($size);

	$table_font->signal_connect( 'clicked', \&change_table_font, $this );
        $table_color->signal_connect( 'clicked', \&change_table_color, $this );
	$border->signal_connect( 'toggled', \&show_table_border, $this, $size );


	$frame->show_all();
}
################################################################3
sub show_table_border{
	my ( $check, $this, $size ) = @_;
	if( $check->active() ){
		$size->set_editable(1);
	}else{
		$size->set_editable(0);
	}
	$this->{REPORT}->show_table( $check->active() );
}
sub change_table_color{
            
        my ( $fgc, $this ) = @_;
            
        my  $colordialog = new Gtk::ColorSelectionDialog( "Select foregroud color" );
        $colordialog->ok_button->signal_connect( "clicked", \&get_table_color, $colordialog, $this );
        $colordialog->cancel_button->signal_connect( "clicked",sub{$colordialog->destroy()} );
        $colordialog->show();
}

sub get_table_color{
        my ( $ok, $colordialog, $this ) = @_;
        $this->{REPORT}->set_table_color( get_color( $colordialog ) );
        $colordialog->destroy();
}
sub change_table_font{
            
        my ( $font, $this ) = @_;
        my $font_dialog = new Gtk::FontSelectionDialog( "Select font" );
        $font_dialog->ok_button->signal_connect( 'clicked',\&get_table_font, $font_dialog, $this );
        $font_dialog->cancel_button->signal_connect( 'clicked',sub {$font_dialog->destroy()} );
        $font_dialog->set_preview_text(" QuickCGI - By Varghese Chacko ");
        $font_dialog->set_filter('user','all',undef,undef,undef,undef,undef,undef);
        $font_dialog->show();
            
}

sub get_table_font{
        my ( $ok, $font_dialog , $this ) = @_;
        my $font = $font_dialog->get_font_name();
            
        my @style = split/-/,$font;
        my $title_style = '';
            
        if( $style[2] ){
            
                $this->{REPORT}->set_table_font_family( 'font-family:'.$style[2].'; ');
        }
            
        if( $style[3] eq 'bold' ){
                $this->{REPORT}->set_table_font_weight( "font-weight: bold; " );
        }else{
                $this->{REPORT}->set_table_font_weight( "" );
        }
            
        if( $style[4] eq 'o' ){
                $this->{REPORT}->set_table_font_style( "font-style: oblique; " );
        }elsif( $style[4] eq 'i' ){
                $this->{REPORT}->set_table_font_style( "font-style: italic; " );
        }elsif( $style[4] eq 'r' ){
                $this->{REPORT}->set_table_font_style( "font-style: roman; " );
        }
            
            
        if( $style[7] && ($style[7] ne '*') ){
                $this->{REPORT}->set_table_font_size( "font-size: ".$style[7]."px; " );
        }elsif( $style[8] && ($style[8] ne '*') ){
                $this->{REPORT}->set_table_font_size( "font-size: ".($style[8]/10)."pt; " );
        }
            
        $font_dialog->destroy();
            
}

#####################################################################################
sub change_title_color{
            
        my ( $fgc, $this ) = @_;
            
        my  $colordialog = new Gtk::ColorSelectionDialog( "Select foregroud color" );
        $colordialog->ok_button->signal_connect( "clicked", \&get_title_color, $colordialog, $this );
        $colordialog->cancel_button->signal_connect( "clicked",sub{$colordialog->destroy()} );
        $colordialog->show();
}

sub get_title_color{
	my ( $ok, $colordialog, $this ) = @_;
	$this->{REPORT}->set_title_color( get_color( $colordialog ) );
	$colordialog->destroy();
}
sub get_color{
            
        my ( $colordialog) = @_;
        my $colorsel = $colordialog->colorsel();
        my @color = $colorsel->get_color();
            
        my $r = $color[0] * 65535.0 / 256;
        my $g = $color[1] * 65535.0 / 256;
        my $b = $color[2] * 65535.0 / 256;
            
        $r = uc( sprintf( "%li", $r ) );
        $g = uc( sprintf( "%li", $g ) );
        $b = uc( sprintf( "%li", $b ) );
            
	return "color: rgb( $r, $g, $b); ";
            
}


sub change_title_font{
            
        my ( $font, $this ) = @_;
        my $font_dialog = new Gtk::FontSelectionDialog( "Select font" );
        $font_dialog->ok_button->signal_connect( 'clicked',\&get_title_font, $font_dialog, $this );
        $font_dialog->cancel_button->signal_connect( 'clicked',sub {$font_dialog->destroy()} );
        $font_dialog->set_preview_text(" QuickCGI - By Varghese Chacko ");
        $font_dialog->set_filter('user','all',undef,undef,undef,undef,undef,undef);
        $font_dialog->show();
            
}
            
sub get_title_font{
        my ( $ok, $font_dialog , $this ) = @_;
        my $font = $font_dialog->get_font_name();
            
        my @style = split/-/,$font;
        my $title_style = '';
	
	if( $style[2] ){
        
		$this->{REPORT}->set_title_font_family( 'font-family:'.$style[2].'; ');
        }

        if( $style[3] eq 'bold' ){
                $this->{REPORT}->set_title_font_weight( "font-weight: bold; " );
        }else{
		$this->{REPORT}->set_title_font_weight( "" );
	}
            
        if( $style[4] eq 'o' ){
                $this->{REPORT}->set_title_font_style( "font-style: oblique; " );
        }elsif( $style[4] eq 'i' ){
                $this->{REPORT}->set_title_font_style( "font-style: italic; " );
        }elsif( $style[4] eq 'r' ){
		$this->{REPORT}->set_title_font_style( "font-style: roman; " );
	}

	
	if( $style[7] && ($style[7] ne '*') ){
                $this->{REPORT}->set_title_font_size( "font-size: ".$style[7]."px; " );
        }elsif( $style[8] && ($style[8] ne '*') ){
                $this->{REPORT}->set_title_font_size( "font-size: ".($style[8]/10)."pt; " );
	}

        $font_dialog->destroy();
            
}

sub closed{
	my ( $style_dialog, $this ) = @_;
	$this->{REPORT}->set_title_style($style_dialog->get_style());
	print $style_dialog->get_style()." \n";
}

sub create_report{
	
	my ($create,$this) = @_;
	my $report = $this->{REPORT};
	
	my $file = "vc.pl";#= $name->get_text();
	
	my $user = $report->get_user_id();
	my $password = $report->get_password();
	my $databasename = $report->get_database();
        my $dsn="DBI:".$report->get_dbms().":$databasename";
	
	my $sql = $report->get_sql();
	my @column_head = $report->get_heads();

	my $title = $report->get_title() || $databasename;

	my $title_style;
	if( $report->get_title_font){
		$title_style = $report->get_title_font();
        }

	open(CGI_FILE,">$file");

	print CGI_FILE "#!/usr/bin/perl","\n";
        print CGI_FILE "use CGI;","\n";
	print CGI_FILE 'use DBI;',"\n";
	print CGI_FILE "use strict;","\n\n";

        print CGI_FILE 'my $q = new CGI;',"\n";
	
	my $string=<<END;
print \$q->start_html( -title=>'$title',
	-head=>\$q->meta( { -http_equiv => "Content-Language", -content => "en-us" } ),
	-meta=>{ 'GENERATOR' => "Quick CGI 0.1",
		'ProgId' => "QuickCGI.PrintReport"
	}),\"\\n\";\n

END

	print CGI_FILE $string;

        print CGI_FILE 'my $dbh = DBI->connect( '."\"$dsn\",\"$user\",\"$password\"".' ) or die send_error( DBI->errstr );',"\n";
        print CGI_FILE 'my $sql = "'.$sql.'";',"\n";
        print CGI_FILE 'my $sth = $dbh->prepare( $sql );',"\n";
        print CGI_FILE '$sth->execute();',"\n";

	print CGI_FILE 'my @column_head	= qw( '.join( ' ',@column_head )." );\n";

	my $border;
	my $table_style; 
	$table_style =  $report->get_table_style();

	if( $report->show_table()){
		$border = 1;
		$table_style = "border-collapse: collapse; ".$table_style;
		if($report->get_table_width()){
			$table_style = $table_style."border: solid ".$report->get_table_width()."px";
		}
	}else{
		$border = 0;
	}

	print CGI_FILE 'print $q->start_table( {-border =>'.$border.', -style => "'.$table_style.'"} ),"\n";'."\n";
	print CGI_FILE 'print $q->'."caption( {-style => \"$title_style\"}, '$title' )".',"\n";'."\n";
	print CGI_FILE 'print $q->Tr( [ $q->th( \@column_head ) ] ),"\n";',"\n\n";

        print CGI_FILE 'while(my @row = $sth->fetchrow_array()){',"\n";
        print CGI_FILE "\t".'print $q->Tr( [ $q->td( \@row ) ] ),"\n";',"\n";
        print CGI_FILE '}',"\n";

        print CGI_FILE 'print $q->end_table(),"\n";',"\n";
        print CGI_FILE 'print $q->end_html(),"\n";',"\n";

        print CGI_FILE 'sub send_error{',"\n";
        print CGI_FILE "\t".'my $string = shift;',"\n";
        print CGI_FILE "\t".'print $string;',"\n";
        print CGI_FILE "\t".'print "</html>"',"\n";
        print CGI_FILE '}',"\n";

#        print CGI_FILE ';',"\n";
#        print CGI_FILE ';',"\n";
#        print CGI_FILE ';',"\n";
	

	close CGI_FILE;


}
1;
