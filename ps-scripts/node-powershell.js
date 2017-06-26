/*jshint esversion:6 */


const shell = require('node-powershell');

let ps = new shell({
    executionPolicy: 'Bypass',
    noProfile: true
});

// ps.addCommand('echo node-powershell');

// ps.invoke()
//     .then(output => {
//         console.log(output);
//     })
//     .catch(err => {
//         console.log(err);
//         ps.dispose();
//     });

ps.addCommand('ls -l c:\\source');
// ps.addCommand("$dataset = Invoke-Sqlcmd -ServerInstance OFFSQLSTDD01 -Database LTLTrack.Demo -Query 'select top 100 * from [dbo].Pro'");
// ps.addCommand("echo $dataset");

ps.invoke()
    .then(output => {
        //alert("here");
        console.log(output);
    })
    .catch(err => {
        console.log(err);
        ps.dispose();
    });