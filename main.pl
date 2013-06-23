#!/usr/bin/perl
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

use strict;
use QuickCGI::Wizard;

my $w = new QuickCGI::Wizard();
$w->show();

true;