#!/usr/bin/perl 
#===============================================================================
#
#         FILE: ts2.pl
#
#        USAGE: ./ts2.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/19/2012 09:21:40 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

no strict 'refs';

my $sub_name = 'test_sub';
eval 'sub $sub_name { print 1; };';

&{$sub_name};
