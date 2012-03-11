####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package PetVM::PetParser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 1 "PetGrammar.yp"

use PetVM qw(%opcodes);
use PetVM::PetLexer;
use Data::Dumper;


sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'' => -1,
			'LABEL' => -1,
			'OP' => -1,
			'error' => 1,
			'OP_JMP' => -1,
			'OP_PUSH' => -1
		},
		GOTOS => {
			'program' => 2
		}
	},
	{#State 1
		DEFAULT => -3
	},
	{#State 2
		ACTIONS => {
			'' => 3,
			'OP' => 6,
			'LABEL' => 5,
			'OP_JMP' => 7,
			'OP_PUSH' => 8
		},
		GOTOS => {
			'expr' => 4
		}
	},
	{#State 3
		DEFAULT => 0
	},
	{#State 4
		DEFAULT => -2
	},
	{#State 5
		DEFAULT => -8
	},
	{#State 6
		DEFAULT => -4
	},
	{#State 7
		ACTIONS => {
			'LABEL_REF' => 9
		}
	},
	{#State 8
		ACTIONS => {
			'NUMBER' => 11,
			'STRING' => 12
		},
		GOTOS => {
			'arg_num' => 10,
			'arg_string' => 13
		}
	},
	{#State 9
		DEFAULT => -7
	},
	{#State 10
		DEFAULT => -5
	},
	{#State 11
		DEFAULT => -9
	},
	{#State 12
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -6
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'program', 0, undef
	],
	[#Rule 2
		 'program', 2, undef
	],
	[#Rule 3
		 'program', 1,
sub
#line 11 "PetGrammar.yp"
{ $_[0]->YYErrok }
	],
	[#Rule 4
		 'expr', 1,
sub
#line 14 "PetGrammar.yp"
{
                                    push @{$_[0]->{YYDATA}->{opcodes}}, 
                                    [$opcodes{$_[0]->_get_opcode_from_keyword($_[1])}];
                                    
                                    return $_[1];
                                }
	],
	[#Rule 5
		 'expr', 2,
sub
#line 20 "PetGrammar.yp"
{
                                    push @{$_[0]->{YYDATA}->{opcodes}}, 
                                    [$opcodes{$_[0]->_get_opcode_from_keyword($_[1])}, [$_[2]]];
                                    
                                    return ($_[1], $_[2]);
                                }
	],
	[#Rule 6
		 'expr', 2,
sub
#line 26 "PetGrammar.yp"
{
                                    push @{$_[0]->{YYDATA}->{opcodes}}, 
                                    [$opcodes{$_[0]->_get_opcode_from_keyword($_[1])}, ["$_[2]"]];
                                    
                                    return ($_[1], $_[2]);
                                }
	],
	[#Rule 7
		 'expr', 2,
sub
#line 32 "PetGrammar.yp"
{
                                    # verify that there is a valid jump point
                                    exists $_[0]->{YYDATA}->{labels}->{$_[2]} or do {
                                        $_[0]->YYData->{ERRMSG} = "Invalid jump point!\n";
                                        $_[0]->YYError;
                                        return undef;
                                    };
                                    
                                    # get the jump point
                                    my $jmp_pt = $_[0]->{YYDATA}->{labels}->{$_[2]};
                                    
                                    # push it on the opcodes stack
                                    push @{$_[0]->{YYDATA}->{opcodes}}, [$opcodes{'OP_PUSH'}, [$jmp_pt]];
                                    
                                    # then we push the jump instruction on the stack as well
                                    push @{$_[0]->{YYDATA}->{opcodes}}, [$opcodes{$_[0]->_get_opcode_from_keyword($_[1])}];
                                    
                                    return ($_[1], $_[2]);
                                }
	],
	[#Rule 8
		 'expr', 1,
sub
#line 51 "PetGrammar.yp"
{
                                    # make the label point one position beyond 
                                    # in the instruction array last instruction.
                                    # we need this because the next instruction 
                                    # is going to be the jump to location
                                    $_[0]->{YYDATA}->{labels}->{$_[1]} = $#{$_[0]->{YYDATA}->{opcodes}}+1;
                                    
                                    return ($_[1]);                            
                                }
	],
	[#Rule 9
		 'arg_num', 1, undef
	],
	[#Rule 10
		 'arg_string', 1, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 71 "PetGrammar.yp"


# convert a keyword to a valid opcode number
sub _get_opcode_from_keyword {
    my $self    = shift;
    my $keyword = shift;
    
    return "OP_$keyword";
}

sub _error {

    exists $_[0]->YYData->{ERRMSG}
    and do {
        print $_[0]->YYData->{ERRMSG}, "\n";
        return $_[0]->YYData->{ERRMSG};
    };
        
    die "Syntax error.\n";
}

sub _lexer {
    my ($self) = @_;
    
    my ($label, $value) = $self->{YYDATA}->{lexer}->token;
    
    return ($label, $value);
}

# init the parser
# expects a valid file handle
sub _init {
    my $self = shift;

    # create the lexer
    my $lexer = new PetVM::PetLexer;
    $lexer->from(@_);
    $self->{YYDATA}->{lexer} = $lexer;
    
    $self->{YYDATA}->{opcodes}  = []; # opcodes array
    $self->{YYDATA}->{labels}   = {}; # labels hash - holds references to opcodes    
    
    return;
}

# parses PetVM assembly language
sub parse {
    my $self = shift;
    my $file = shift;
    
    $self->_init($file);
    
    $self->YYParse( yylex => \&_lexer, yyerror => \&_error, yydebug => 0x0 );
    
    return;
}

# returns an array ref of opcodes
sub get_opcodes {
    my $self = shift;
    
    return $self->{YYDATA}->{opcodes};
}

__END__

=head1 NAME

B<PetVM> parser definition.

=head1 SYNOPSIS

 use PetVM::PetParser;

 my $parser = PetVM::PetParser->new;
 
 $parser->parse( IO::Scalar->new( \$buf ) );
 
 my $instructions = $parser->get_opcodes();

=head1 DESCRIPTION

This is the Parse::Yapp based parser module for B<PetVM>. For the grammar definition please refer to PetGrammar.yp.

=head1 METHODS

=head2 new

my $parser = PetVM::PetParser->new;

The C<new> method creates a new B<PetVM::PetParser> object.

=head2 parse

$parser->parse( IO::Scalar->new( \$buf ) );

The C<parse> method parses B<PetVM> assembly code. It expects a valid file handle as a parameter.

=head2 get_opcodes

$parser->get_opcodes;

The C<get_opcodes> returns an array ref of valid opcodes that B<PetVM> understands.

=head1 AUTHOR

Dmitriy Ryajov, <dryajov@gmail.com> 

=cut


1;
