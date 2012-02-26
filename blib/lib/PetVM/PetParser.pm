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
use Parse::Yapp::Driver;

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
                                    [$opcodes{$_[0]->get_opcode_from_keyword($_[1])}];
                                    
                                    return $_[1];
                                }
	],
	[#Rule 5
		 'expr', 2,
sub
#line 20 "PetGrammar.yp"
{
                                    push @{$_[0]->{YYDATA}->{opcodes}}, 
                                    [$opcodes{$_[0]->get_opcode_from_keyword($_[1])}, [$_[2]]];
                                    
                                    return ($_[1], $_[2]);
                                }
	],
	[#Rule 6
		 'expr', 2,
sub
#line 26 "PetGrammar.yp"
{
                                    push @{$_[0]->{YYDATA}->{opcodes}}, 
                                    [$opcodes{$_[0]->get_opcode_from_keyword($_[1])}, ["$_[2]"]];
                                    
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
                                    push @{$_[0]->{YYDATA}->{opcodes}}, [$opcodes{$_[0]->get_opcode_from_keyword($_[1])}];
                                    
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

#line 69 "PetGrammar.yp"


sub get_opcode_from_keyword {
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

sub init {
    my $self = shift;

    # create the lexer
    my $lexer = new PetVM::PetLexer;
    $lexer->from(@_);
    $self->{YYDATA}->{lexer} = $lexer;
    
    $self->{YYDATA}->{opcodes}  = []; # opcodes array
    $self->{YYDATA}->{labels}   = {}; # labels hash - holds references to opcodes    
    
    return;
}

sub parse {
    my $self = shift;
    my $file = shift;
    
    $self->init($file);
    
    $self->YYParse( yylex => \&_lexer, yyerror => \&_error, yydebug => 0x0 );
    
    return;
}

sub get_opcodes {
    my $self = shift;
    
    return $self->{YYDATA}->{opcodes};
}

1;
