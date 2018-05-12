#!/usr/bin/perl
# ./npcmubook.pl level int mubooks.org nonoknows
# if nonoknows is set then the program will not output
# the spells that the MU specifically failed their
# "know spell" roll on

$lv=shift || die("What level and INT is the NPC magic user?\n");
$int=shift || die("What INT is the NPC magic user?\n");
$masterfile=shift || 'mubooks.org';
$nonoknows = shift ;

@numspells=spellsneeded($lv);
@maxspells=((-1)x9,6,(7)x3,(9)x2,(11)x2,14,18);
@knowspell=((-1)x9,35,(45)x3,(55)x2,(65)x2,75,85,95,96,97,98,99,100,100);

$C=650;
$U=200;
$R=110;
$V=40;
$X=10000; # Special for "always take"
$,=',';

%allspells=();

$L=1;
foreach $level(@numspells)
{
    last if($L>$int/2);
    my $limit=$maxspells[$int];

    $limit=1e6 if !defined($limit);

    if($L==1)
    {
        $level+=4;
    }

    $level=$level+($lv-firstget($L));
    
    $level=min($level,$limit);
    
    @thesespells=();
    @unknown=();

    while(@thesespells < $level)
    {
        my $spell=getspell($L,$masterfile);
        if($spell)
        {
            if ($spell eq 'Read Magic' || roll(1,100) <= $knowspell[$int])
            {
                push @thesespells,$spell
            }
            else
            {
                push @unknown, ($spell);
            }
            $allspells{$spell}=1;
        }
        else
        {
            last;
        }
    }
    
   
    {
        my $c=@thesespells;
        print "Level $L ($c @ ${knowspell[$int]}):\n";
        local $,="\n";
        if(!$nonoknows && @unknown)
        {
            @unknown=sort @unknown;
            print "Don't know:\n";
            print @unknown;
            print "\n\n";
        }
        print "Know:\n";
        @thesespells=sort @thesespells;
        print @thesespells;
    }
    $L++;
    print "\n\n";
}

sub roll
{
    my $n=shift;
    my $sides=shift;
    my $bonus=shift || 0;

    if($n==0)
    {
        return $bonus;
    }
    
    if($n<1)
    {
        $sides*=$n;
        $n=1;
    }
    
    my $result=0;

    for(1..$n)
    {
        $result+=int(rand($sides)+1);
    }

    $result+=$bonus;

    $result=1 if $result < 1;
    return $result;
}

sub sum
{
    my $tot=0;

    while(my $n=shift)
    {
        $tot+=$n;
    }
    return $tot;
}

sub min
{
    my $r=shift;

    for my $n(@_)
    {
        $r=$n if $n<$r;
    }

    return $r;
}

sub spellsneeded
{
    my @table=([],
               [ 1 ],
               [ 2 ],
               [ 3 , 1 ],
               [ 3 , 2 ],
               [ 4 , 2 , 1],
               [ 4 , 2 , 2],
               [ 4 , 3 , 2 , 1],
               [ 4 , 3 , 3 , 2],
               [ 4 , 3 , 3 , 2 , 1],
               [ 4 , 4 , 3 , 2 , 2],
               [ 4 , 4 , 4 , 3 , 3],
               [ 4 , 4 , 4 , 4 , 4 , 1],
               [ 5 , 5 , 5 , 4 , 4 , 2],
               [ 5 , 5 , 5 , 4 , 4 , 2 , 1],
               [ 5 , 5 , 5 , 5 , 5 , 2 , 1],
               [ 5 , 5 , 5 , 5 , 5 , 3 , 2 , 1],
               [ 5 , 5 , 5 , 5 , 5 , 3 , 3 , 2],
               [ 5 , 5 , 5 , 5 , 5 , 3 , 3 , 2, 1],
               [ 5 , 5 , 5 , 5 , 5 , 3 , 3 , 3, 1],
               [ 5 , 5 , 5 , 5 , 5 , 4 , 3 , 3, 2],
               [ 5 , 5 , 5 , 5 , 5 , 4 , 4 , 4, 2],
               [ 5 , 5 , 5 , 5 , 5 , 5 , 4 , 4, 3],
               [ 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5, 3],
               [ 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5, 4],
               [ 5 , 5 , 5 , 5 , 5 , 5 , 5 , 5, 5],
               [ 6 , 6 , 6 , 6 , 5 , 5 , 5 , 5, 5], 
        );

    my $lv=shift;

    $lv=26 if $lv>26;

    return @{$table[$lv]};
}

sub firstget
{
    my $spelllv=shift;
    if($spelllv<6)
    {
        return $spelllv*2-1;
    }
    else
    {
    return $spelllv*2;
    }
}

sub getspell
{
    my $lv=shift;
    my $masterfile=shift;
    my $result='';

    die("Can't open file $masterfile\n") unless open(my $fh ,'<',$masterfile);
    <$fh>; #Discard headings 
    <$fh>; #Discard divider

    my $tw=0;
    
    while(<$fh>)
    {
        chomp;
        if($_)
        {
            my $weight=0;

            @parts=split/\s*\|\s*/;
            shift @parts;  #empty 1st col
            $spell=$parts[($lv-1)*2];
            $freq=$parts[($lv-1)*2+1];
            $freq=0 if $allspells{$spell};
            
            if($spell && $freq)
            {
                if($freq>0) # Is a number, not a letter code
                {
                    $weight=$freq
                }
                elsif($freq ne '')
                {
                    $weight=$$freq;
                }

                if($weight>0)
                {
                    $tw+=$weight;
                    if($freq eq 'X' or rand()<$weight/$tw)
                    {
                        $result=$spell;
                    }
                }
            }
        }
    }
    close $fh;
    return $result;
}
