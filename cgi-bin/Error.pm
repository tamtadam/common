#!"C:\xampp\perl\bin\perl.exe"

package Error;
use strict;
use warnings;
use Data::Dumper;

our $VERSION = '0.02';

use constant {
    DB_SELECT               => 'DB_SELECT',
    FEA_LIST                => 'FEA_LIST',
    GHERKIN_WORDS           => 'GHERKIN_WORDS', 
    DB_ITEMNAME             => 'DB_ITEMNAME', 
    DB_SCREENNAME           => 'DB_SCREENNAME',
    SCENARIO_LIST           => 'SCENARIO_LIST',
    COMM_LIST               => 'COMM_LIST',
    SCEN_WITH_DATAS         => 'SCEN_WITH_DATAS',
    REFIMAGES_BY_FEA        => 'REFIMAGES_BY_FEA', 
    SCENLIST_BY_FEA         => 'SCENLIST_BY_FEA', 
    DEL_SCEN_FROM_FEA       => 'SCENLIST_BY_FEA', 
    SAVE_SCENARIOS_FOR_FEAS => 'SAVE_SCENARIOS_FOR_FEAS',
    GHERKIN_TEXT            => 'GHERKIN_TEXT',
    SAVE_FEATURE_TEXT       => 'SAVE_FEATURE_TEXT',
    IsValid_1               => 'IsValid_1',
    IsValid_0               => 'IsValid_0',
    DB_ITEMONSCREEN         => 'DB_ITEMONSCREEN', 
    NEW_SCENARIO            => 'NEW_SCENARIO', 
    DELETE_SCENARIO         => 'DELETE_SCENARIO', 
    SCREENSHOT_FAILURE      => 'SCREENSHOT_FAILURE', 
    SCENARIO_WITH_SENT      => 'SCENARIO_WITH_SENT', 
    REGION_ON_SCREENSHOT    => 'REGION_ON_SCREENSHOT',
    SCREENSHOTMODE          => 'SCREENSHOTMODE',
    LOCKUNLOCK              => 'LOCKUNLOCK',
    SCREENSHOT_BY_FEA       => 'SCREENSHOT_BY_FEA', 
    DB_VALUES               => 'DB_VALUES', 
    ACT_INFOS               => 'ACT_INFOS',
    DB_ITEM_ON_SCREEN       => 'DB_ITEM_ON_SCREEN',
    TEST_ALL_DATAS          => 'TEST_ALL_DATAS', 
    TEST_BY_TESTCASE        => 'TEST_BY_TESTCASE',
    ADD_TESTCASE            => 'ADD_TESTCASE',
    PASSED_TESTS            => 'PASSED_TESTS',
    ADD_TEST                => 'ADD_TEST', 
    ADD_NEW_VERSION         => 'ADD_NEW_VERSION',
    ADD_TESTCASETYPE        => 'ADD_TESTCASETYPE',
    ADD_RESULT              => 'ADD_RESULT',
    ADD_PROJECT             => 'ADD_PROJECT',
    ADD_TEST_CASE           => 'ADD_TEST_CASE',
    PROJECTS                => 'PROJECTS', 
    TEST_CASE_TYPES         => 'TEST_CASE_TYPES',
    TESTCASES_BY_REVISION   => 'TESTCASES_BY_REVISION',
    PASSED_TCs_BY_REV       => 'PASSED_TCs_BY_REV',
    LATEST_REVISION         => 'LATEST_REVISION',     
    ALL_TCs_TYPE            => 'ALL_TCs_TYPE',
    REGION                  => 'REGION',
    TEST_TYPE               => 'TEST_TYPE',
};

my $ERROR_CODES = {
    "DB_SELECT"                => "Selection from db. does not response", 
    "FEA_LIST"                 => "No avalaible feature in db. ", 
    "SCENARIO_LIST"            => "No avalaible scneaio in db. ", 
    "GHERKIN_WORDS"            => "No Gherkin words found in db.",   
    "DB_ITEMNAME"              => "No Item found in db.", 
    "DB_SCREENNAME"            => "No Screen found in db.",
    "COMM_LIST"                => "No Communication Line found in db.",
    "SCEN_WITH_DATAS"          => "No scenario with sentences found in db.", 
    "REFIMAGES_BY_FEA"         => "No refimages found in db. to feature",
    "SCENLIST_BY_FEA"          => "No scenarios in feature in db.",
    "DEL_SCEN_FROM_FEA"        => "Unsuccessful deleting scenario from feature",
    "SAVE_SCENARIOS_FOR_FEAS"  => "Unsuccessful saving scenarios in feature",
    "GHERKIN_TEXT"             => "Selection from db. does not response",
    "SAVE_FEATURE_TEXT"        => "Feature file is not saved ",
    "IsValid_1"                => "IsValid_1 is not updated in Screenshot table",
    "IsValid_0"                => "IsValid_0 is not updated in Screenshot table",
    "DB_ITEMONSCREEN"          => "There is no Item on this Screen!",
    "NEW_SCENARIO"             => "Failed parameter! Scenario is not add to ScenarioList!",
    "DELETE_SCENARIO"          => "Scenario is not deleted!",
    "SCREENSHOT_FAILURE"       => "There is not such a screenshot!",
    "SCENARIO_WITH_SENT"       => "ScenarioID or SentenceList is missing!!",
    "REGION_ON_SCREENSHOT"     => "There are no Regions on this Screenshot!",
    "SCREENSHOTMODE"           => "There aren't ScreenshotModes available",
    "LOCKUNLOCK"               => "Locked status request is failed",  
    "SCREENSHOT_BY_FEA"        => "Screenshot request is failed", 
    "DB_VALUES"                => 'Values from CompleteSentence table request is failed', 
    "ACT_INFOS"                => 'Actual test infos request is failed',
    "DB_ITEM_ON_SCREEN"        => 'No Item on actual Screen', 
    "TEST_ALL_DATAS"           => 'No Tests are avalaible', 
    "TEST_BY_TESTCASE"         => 'No Tests are avalaible by this testcasetype', 
    "ADD_TESTCASE"             => 'Testcase is not added to database',
    "PASSED_TESTS"             => 'No Tests are avalaible by this testcasetype', 
    "ADD_TEST"                 => 'No Tests are avalaible by this testcasetype', 
    "ADD_NEW_VERSION"          => 'New Version is not inserted to Version table',    
    "ADD_TESTCASETYPE"         => 'TestCase type is not inserted to TestCaseType table',    
    "ADD_RESULT"               => 'Result is not inserted to Result table',    
    "ADD_PROJECT"              => 'Project is not inserted to Project table',    
    "ADD_TEST_CASE"            => 'Test Case is not inserted to TestCase table', 
    "PROJECTS"                 => 'There are no projects defined', 
    "TEST_CASE_TYPES"          => 'There are no testcase types defined',  
    "TESTCASES_BY_REVISION"    => 'There are no testcases by this revision',
    "PASSED_TCs_BY_REV"        => 'There are no passed testcases by this revision',  
    "LATEST_REVISION"          => 'There are no revision by this projectID and TesCaseTypeID',
    "ALL_TCs_TYPE"             => 'There are no testcases by this TesCaseTypeID',    
    "REGION"                   => 'Region request is failed',
    "TEST_TYPE"                => 'Test_type request is failed',      
} ;

sub new {
    my ($class) = shift;

    my $self = {};

    bless( $self, $class );
    $self->init;
    return $self;
}

sub init {
    my $self = shift;
    $self->{ 'ERROR_CODES' } = [] ;
    $self->{ 'TIMES' } = [] ;
    $self;
}

sub add_error{
    my $self = shift ;
    push @{ $self->{ 'ERROR_CODES' } }, $self->get_error_text( shift ) ;
}


sub get_error_text{
    my $self = shift ;
    my $error_id = shift ;
    
    if ( defined $ERROR_CODES->{ $error_id } ){
        return $ERROR_CODES->{ $error_id } ;
    } else {
        return "$error_id does not found" ;
    }
}

sub get_errors{
    my $self = shift ;
    return $self->{ 'ERROR_CODES' } ;
}

sub empty_errors{
    my $self = shift ;
    $self->{ 'ERROR_CODES' } = [] ;
    
}

1;