#!/usr/bin/perl

$lv=shift || die("What level is the NPC magic user?\n");
$masterfile=shift || 'mumemorised.org';

@numspells=spellsneeded($lv);

$C=650;
$U=200;
$R=110;
$V=40;
$,=',';

$L=1;
foreach $level(@numspells)
{
    print "Level $L:\n";
    @thesespells=();
    for(1..$level)
    {
        push @thesespells,getspell($L,$masterfile);       
    }
    $L++;
    {
        local $,="\n";
        @thesespells=sort @thesespells;
        print @thesespells;
    }
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

sub getspell
{
    my $lv=shift;
    my $masterfile=shift;
    my $result='+++Error+++';

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
                    if(rand()<$weight/$tw)
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
