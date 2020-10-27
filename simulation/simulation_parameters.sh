
# death rate is fixed to 1 throughout
death_rate_0="1.0"
death_rate_1="1.0"

# specify parameters cases

## epidemic case: high growth
birth_rate_0="1.5"
birth_rate_1="1.5"

# high migration
if [ $1 = "case_45" ]
then
    migration_rate_01="1.0"
    migration_rate_10="1.0"
    nLineages="300"

# low migration
elif [ $1 = "case_46" ]
then
    migration_rate_01="0.1"
    migration_rate_10="0.1"
    nLineages="300"

elif [ $1 = "case_47" ]
then
    migration_rate_01="0.01"
    migration_rate_10="0.01"
    nLineages="300"

elif [ $1 = "case_48" ]
then
    migration_rate_01="1.0"
    migration_rate_10="1.0"
    nLineages="100"

elif [ $1 = "case_49" ]
then
    migration_rate_01="0.1"
    migration_rate_10="0.1"
    nLineages="100"

elif [ $1 = "case_50" ]
then
    migration_rate_01="0.01"
    migration_rate_10="0.01"
    nLineages="100"

elif [ $1 = 'case_51' ]
then
    backmigration_rate_01=1.0
    backmigration_rate_10=1.0
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_52' ]
then
    backmigration_rate_01=0.1
    backmigration_rate_10=0.1
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_53' ]
then
    backmigration_rate_01=0.01
    backmigration_rate_10=0.01
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/75; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_54' ]
then
    backmigration_rate_01=1.0
    backmigration_rate_10=1.0
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_55' ]
then
    backmigration_rate_01=0.1
    backmigration_rate_10=0.1
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_56' ]
then
    backmigration_rate_01=0.01
    backmigration_rate_10=0.01
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/1000; if(x<1) print 0; x" | bc -l` 
elif [ $1 = 'case_57' ]
then
    backmigration_rate_01=1.0
    backmigration_rate_10=1.0
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_58' ]
then
    backmigration_rate_01=0.1
    backmigration_rate_10=0.1
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_59' ]
then
    backmigration_rate_01=0.01
    backmigration_rate_10=0.01
    # coming from Ne = N0/(2 birthrate) = 150 /2
    # cr = 1/Ne
    coalescence_rate_0=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 
    coalescence_rate_1=`echo "x=1/500; if(x<1) print 0; x" | bc -l` 

elif [ $1 = 'case_??' ]
then
    # debug BD inference - simulate under ~ similar conditions using BD as with SC and case_51 
    birth_rate_0="1.0"
    birth_rate_1="1.0"
    migration_rate_01="1.0"
    migration_rate_10="1.0"
    nLineages="300"

# debugging case
elif [ $1 = "case_100" ]
then
    migration_rate_01="0.01"
    migration_rate_10="0.01"
    nLineages="20"
    
else
    echo "This case has not been specified so far!"
    exit
fi
