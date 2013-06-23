package StyleDialog;

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
use strict;

sub new{
	
	my $class = shift;
	my $this = {};
	$this->{dialog} = new Gtk::Window();
	$this->{dialog}->set_title( "Give style to your title" );

	my $fixed = new Gtk::Fixed();
	my $lbltitle = new Gtk::Label( "Set style of the Title" );

	my $fg_color = new Gtk::ToggleButton( " Text Color " );
	my $ok = new Gtk::Button( " OK " );

	my $font = new Gtk::Button( " Font " );

	$fixed->put( $lbltitle, 13, 13 );

	$fixed->put( $font, 10, 40 );
        $fixed->put( $fg_color, 60, 40 );

	$fixed->put( $ok, 360, 170 );

	$this->{dialog}->add( $fixed );
	$this->{dialog}->set_usize( 400, 200 );	

	$this->{style} = {};
	$ok->signal_connect( 'clicked', \&on_ok,$this);
	$font->signal_connect( 'clicked', \&select_font, $this );
	$fg_color->signal_connect( 'clicked', \&select_fg_color, $this );

	$fixed->show_all();
	bless( $this, $class );
	return $this;	
	
}

sub dialog{
	return $_[0]->{dialog};
}
sub get_style{

	my $this = shift;
#	print $this->{style}->{color}.$this->{style}->{font}."\n";
#	return $this->{style}->{color} $this->{style}->{font};
	return "color: #000000"
}

sub select_fg_color{

	my ( $fgc, $this ) = @_;

	my  $colordialog = new Gtk::ColorSelectionDialog( "Select foregroud color" );
	$colordialog->ok_button->signal_connect( "clicked", \&get_fg_color, $colordialog, $this );
	$colordialog->cancel_button->signal_connect( "clicked",sub{$colordialog->destroy()} );
	$colordialog->show();	
}

sub get_fg_color{

	my ( $ok, $colordialog, $this ) = @_;
	my $colorsel = $colordialog->colorsel();
	my @color = $colorsel->get_color();

	my $r = $color[0] * 65535.0 / 256;
        my $g = $color[1] * 65535.0 / 256;
        my $b = $color[2] * 65535.0 / 256;	

	$r = uc( sprintf( "%lx", $r ) );
	$g = uc( sprintf( "%lx", $g ) );
	$b = uc( sprintf( "%lx", $b ) );

#print "#$r$g$b\n";

	$this->{style}->{color} = "color: #$r$g$b";

	$colordialog->destroy();
}

sub select_font{

	my ( $font, $this ) = @_;
	my $font_dialog = new Gtk::FontSelectionDialog( "Select font" );
	$font_dialog->ok_button->signal_connect( 'clicked',\&get_font, $font_dialog, $this );
	$font_dialog->cancel_button->signal_connect( 'clicked',sub {$font_dialog->destroy()} );
	$font_dialog->set_preview_text(" QuickCGI - By Varghese Chacko ");
	$font_dialog->set_filter('user','all',undef,undef,undef,undef,undef,undef);
	$font_dialog->show();

}

sub get_font{
	my ( $ok, $font_dialog , $this ) = @_;
	my $font = $font_dialog->get_font_name();

	my @style = split/-/,$font;
	my $title_style = '';
	$title_style = 'font-family:'.$style[2].'; ';
	if($style[3] eq 'bold' ){
		$title_style = $title_style."font-weight: bold; ";
	}

	if($style[4] eq 'o' || $style[4] eq 'i' ){
                $title_style = $title_style."font-style: italic; ";
        }
	
	if($style[7] ){
                $title_style = $title_style."font-size: ".$style[7]."px; ";
        }else{
		$title_style = $title_style."font-size: ".($style[7]/10)."pt; ";
	}
	
	$this->{style}->{font} = $title_style;
	$font_dialog->destroy();
	
}

sub on_ok{

	my ( $ok, $this) = @_;

	$this->{dialog}->destroy();

}

sub show{
	$_[0]->{dialog}->show_all();
	$_[0]->{dialog}->show();
}
1;
