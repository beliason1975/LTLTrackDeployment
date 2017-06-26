"use strict";

var prompt = require('prompt');
var shell = require('node-powershell');

var ps = new shell({ executionPolicy: 'Bypass', debugMsg: true });


var SERVER_OFFSQLENTD01 = "OFFSQLENTD01";
var SERVER_OFFSQLSTDD01 = "OFFSQLSTDD01";
var DATABASE_COYOTE = "COYOTE";
var DATABASE_MCLEOD = "McLeodData_LTL"
var DATABASE_LTLTRACK = "LTLTrack_Dev";
var TABLE_PRODATAWH = "ProDataWH";
var DEFAULT_SCHEMA = "dbo";
// var TABLE_PRO = "Pro";
// var TABLE_PROTRUCK = "ProTruck";
// var PROCESS_CHANGES = "y";

//
// Start the prompt
//
prompt.start();

var property = {
    name: 'yesno',
    message: 'Enter y to process changes or enter n to start new',
    validator: /^(y|Y)|(n|N)$/,
    warning: 'Must respond [y] or [n]',
    default: 'y'
};

function onErr(err) {
    console.log(err);
    return 1;
}

function ProcessChangesOnly() {
    ps.addCommand('.\\ps-scripts\\Truncate_Table_ProDataWH.ps1', [
        { name: 'server', value: SERVER_OFFSQLSTDD01 },
        { name: 'database', value: DATABASE_LTLTRACK }
    ]);

    return ps.invoke();
}

function ProcessNewDatabase() {
    ps.addCommand('.\\ps-scripts\\Truncate_All_LTLTrack_Tables.ps1', [
        { name: 'server', value: SERVER_OFFSQLSTDD01 },
        { name: 'database', value: DATABASE_LTLTRACK },
        { name: 'inputFile', value: '.\\sql\\TruncateLTLTables.sql' }
    ]);

    return ps.invoke();
}

//
// Get the simple yes or no property
//
prompt.get(property, function(err, result) {
    console.log("entered prompt callback function)\n");

    if (err) {
        return onErr(err);
    }

    console.log('Command-line input received:');
    console.log('  Processing Changes: ' + result.yesno);

    if (result.yesno === 'y' || result.yesno === 'Y') {
        console.log("Processing changes only.");

        ProcessChangesOnly()
            .then(function(output) {
                console.log(output);
                RunScripts(output);
            });

    } else {
        console.log("Processing new database.");

        ProcessNewDatabase()
            .then(function(output) {
                console.log(output);
                RunScripts(output);
            });
    }
});

function RunScripts(output) {
    ps.addCommand('Write-Host "Starting powershell scripts for LTLTrack&Trace."');
    ps.invoke()
        .then(output => {
            console.log(output);
            ps.addCommand('.\\ps-scripts\\Insert_Into_ProDataWH_CoyoteData.ps1', [
                { name: 'server', value: SERVER_OFFSQLENTD01 },
                { name: 'database', value: DATABASE_COYOTE },
                { name: 'inputFile', value: '.\\sql\\RefreshProDataWH_OpenQuery.sql' },
                { name: 'outServer', value: SERVER_OFFSQLSTDD01 },
                { name: 'outDatabase', value: DATABASE_LTLTRACK },
                { name: 'outTable', value: TABLE_PRODATAWH },
                { name: 'schema', value: DEFAULT_SCHEMA }
            ]);
            ps.invoke()
                .then(output => {
                    console.log(output);
                    ps.addCommand('.\\ps-scripts\\Insert_New_Pros.ps1', [
                        { name: 'server', value: SERVER_OFFSQLSTDD01 },
                        { name: 'database', value: DATABASE_LTLTRACK },
                        { name: 'inputFile', value: '.\\sql\\InsertNewPros.sql' }
                    ]);
                    ps.invoke()
                        .then(output => {
                            console.log(output);
                            ps.addCommand('.\\ps-scripts\\Insert_New_ProTrucks.ps1', [
                                { name: 'server', value: SERVER_OFFSQLSTDD01 },
                                { name: 'database', value: DATABASE_LTLTRACK },
                                { name: 'inputFile', value: '.\\sql\\InsertNewProTrucks.sql' }
                            ]);
                            ps.invoke()
                                .then(output => {
                                    console.log(output);
                                    ps.addCommand('.\\ps-scripts\\Set_Flag_Non_Active_ProTrucks.ps1', [
                                        { name: 'server', value: SERVER_OFFSQLSTDD01 },
                                        { name: 'database', value: DATABASE_LTLTRACK },
                                        { name: 'inputFile', value: '.\\sql\\SetFlagNonActiveProTrucks.sql' }
                                    ]);
                                    ps.invoke()
                                        .then(output => {
                                            console.log(output);
                                            console.log('History:' + ps.history);
                                            ps.dispose();
                                        })
                                        .catch(err => {
                                            console.log(err);
                                            ps.dispose();
                                        });
                                })
                                .catch(err => {
                                    console.log(err);
                                    ps.dispose();
                                })
                        })
                        .catch(err => {
                            console.log(err);
                            ps.dispose();
                        })
                })
                .catch(err => {
                    console.log(err);
                    ps.dispose();
                })
        })
        .catch(err => {
            console.log(err);
            ps.dispose();
        })
}
// .catch(err => {
//     console.log(err);
//     ps.dispose();
// })
