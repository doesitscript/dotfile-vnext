(Started at <Not yet started>). Bailing out.
2026-03-15 14:14:03.347462-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.60, Rationale: [{batteryLevel == 26 AND pluggedIn == 1}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
 ] sumScores:43.121357, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.888734}
2026-03-15 14:14:03.347486-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B' has compatibility score of -1.000000 with 501:com.apple.ap.promotedcontentd.gc:D6F32D (Started at <Not yet started>). Bailing out.
2026-03-15 14:14:18.429516-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.60, Rationale: [{batteryLevel == 26 AND pluggedIn == 1}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
 ] sumScores:43.121357, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.888734}
2026-03-15 14:14:18.429540-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B' CurrentScore: 0.888734, ThresholdScore: 0.694377 DecisionToRun:1
2026-03-15 14:14:18.432571-0500 0x18697    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] REQUESTING START: 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B
2026-03-15 14:14:18.531869-0500 0x185d5    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Initiating XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 14:14:18.532391-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: beginning dispatch, activity name com.apple.XProtect.PluginService.agent.fast.scan, seqno 1
2026-03-15 14:14:18.532395-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640): found an activity with matching seqno 1
2026-03-15 14:14:18.532410-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_begin_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 14:14:18.532433-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: lower half, activity name com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), seqno from top half was 1
2026-03-15 14:14:18.532460-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: created connection 0x7ff2a7704b40 for activity name com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), seqno 1
2026-03-15 14:14:18.532461-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 14:14:18.532464-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 14:14:18.533679-0500 0x185d5    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Running XPC Activity (PID 9699): com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 14:14:18.533880-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 2
2026-03-15 14:14:18.533883-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 0
2026-03-15 14:14:18.533886-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 14:14:18.535935-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] STARTING activity 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B <private>!
2026-03-15 14:14:18.536588-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B has been running for 1.849730809529622e-06 minutes
2026-03-15 14:14:18.537091-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.60, Rationale: [{batteryLevel == 26 AND pluggedIn == 1}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
 ] sumScores:43.121357, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.888734}
2026-03-15 14:14:19.736170-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 14:14:19.736175-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__ returned from handler: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 5
2026-03-15 14:14:19.736176-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 14:14:19.736185-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 14:14:19.736226-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 14:14:19.736314-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 14:14:19.736382-0500 0x18697    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Completed XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 14:14:19.737030-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] COMPLETED 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B at priority 30 <private>!
2026-03-15 14:14:19.737128-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle(activityGroup)] NO LONGER RUNNING 501:com.apple.XProtect.PluginService.agent.fast.scan:BB0E3B ...Tasks running in group [com.apple.dasd.default] are 2!
2026-03-15 14:14:19.737502-0500 0x18697    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Rescheduling XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 14:14:19.737701-0500 0x18697    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] SUBMITTING: 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329
2026-03-15 14:14:19.737909-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 1
2026-03-15 14:14:19.737924-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_end_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 14:14:19.743292-0500 0x18538    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:default] Submitted Activity: 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329 at priority 30 with interval 21600 <private>
2026-03-15 15:00:40.336262-0500 0x1df0e    Default     0x0                  1      0    launchd: [pid/11627 [DictationIM]:] Service stub created for com.apple.XProtectFramework.UpdateService
2026-03-15 15:23:16.668110-0500 0x219d9    Default     0x0                  1      0    launchd: [pid/12634 [DictationIM]:] Service stub created for com.apple.XProtectFramework.UpdateService
2026-03-15 15:25:52.043879-0500 0x22362    Default     0x0                  1      0    launchd: [pid/12738 [DictationIM]:] Service stub created for com.apple.XProtectFramework.UpdateService
2026-03-15 15:29:03.351134-0500 0x22c34    Default     0x0                  1      0    launchd: [pid/12958 [DictationIM]:] Service stub created for com.apple.XProtectFramework.UpdateService
2026-03-15 16:10:16.346823-0500 0x27858    Default     0x0                  1      0    launchd: [pid/14531 [DictationIM]:] Service stub created for com.apple.XProtectFramework.UpdateService
2026-03-15 17:07:02.030759-0500 0x2b8df    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 17:07:03.263731-0500 0x2b827    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 17:07:12.651482-0500 0x2b974    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 17:07:24.887760-0500 0x2bb1e    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:28.102302-0500 0x2bc1e    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:28.102540-0500 0x2bc1e    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:29.389948-0500 0x2bca8    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:29.391413-0500 0x2bca8    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:47.217620-0500 0x2be67    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:47.218577-0500 0x2be67    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:51.068231-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:19:51.069176-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:03.113181-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:03.113861-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:04.401129-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:04.401473-0500 0x2be87    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:19.865496-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:19.865848-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 18:55:34.976685-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:34.976698-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50' CurrentScore: 0.795345, ThresholdScore: 0.701929 DecisionToRun:1
2026-03-15 18:55:34.976932-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:34.976944-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329' has compatibility score of -1.000000 with 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 (Started at <Not yet started>). Bailing out.
2026-03-15 18:55:34.976952-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 has been running for 0 minutes
2026-03-15 18:55:34.978713-0500 0x2c3f0    Default     0x0                  71     8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] REQUESTING START: 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50
2026-03-15 18:55:35.030098-0500 0x2bfe2    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Initiating XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 18:55:35.032759-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: beginning dispatch, activity name com.apple.XProtect.PluginService.daemon.fast.scan, seqno 1
2026-03-15 18:55:35.032821-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0): found an activity with matching seqno 1
2026-03-15 18:55:35.032968-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_begin_running: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0) seqno: 1.
2026-03-15 18:55:35.033014-0500 0x17453    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: lower half, activity name com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), seqno from top half was 1
2026-03-15 18:55:35.033122-0500 0x17453    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: created connection 0x7ff13a904c80 for activity name com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), seqno 1
2026-03-15 18:55:35.033123-0500 0x17453    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 2
2026-03-15 18:55:35.033125-0500 0x17453    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 2
2026-03-15 18:55:35.038501-0500 0x2bfe2    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Running XPC Activity (PID 9698): com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 18:55:35.038659-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), set activity state to 2
2026-03-15 18:55:35.038668-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), current state 2, pending state 0
2026-03-15 18:55:35.038705-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 4
2026-03-15 18:55:35.045683-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] STARTING activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 <private>!
2026-03-15 18:55:35.046121-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 has been running for 1.265605290730794e-06 minutes
2026-03-15 18:55:35.046319-0500 0x2bffc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:36.918339-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 has been running for 0.03120328187942505 minutes
2026-03-15 18:55:36.918746-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:36.920531-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:36.920600-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329' has compatibility score of -1.000000 with 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 (Started at Sun Mar 15 18:55:35 2026). Bailing out.
2026-03-15 18:55:36.920615-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 has been running for 0.0312344491481781 minutes
2026-03-15 18:55:37.005395-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 5
2026-03-15 18:55:37.005400-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__ returned from handler: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), current state 2, pending state 5
2026-03-15 18:55:37.005401-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 1
2026-03-15 18:55:37.005410-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 4
2026-03-15 18:55:37.005456-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 5
2026-03-15 18:55:37.005487-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 1
2026-03-15 18:55:37.005639-0500 0x2bfe2    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Completed XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 18:55:37.006300-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] COMPLETED 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 at priority 30 <private>!
2026-03-15 18:55:37.006396-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle(activityGroup)] NO LONGER RUNNING 0:com.apple.XProtect.PluginService.daemon.fast.scan:3B1C50 ...Tasks running in group [com.apple.dasd.default] are 1!
2026-03-15 18:55:37.008606-0500 0x2bfe2    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Rescheduling XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 18:55:37.008741-0500 0x2bfe2    Default     0x0                  71     8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] SUBMITTING: 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9
2026-03-15 18:55:37.008915-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), set activity state to 1
2026-03-15 18:55:37.008928-0500 0x2c40d    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_end_running: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0) seqno: 1.
2026-03-15 18:55:37.010767-0500 0x2c1ad    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:default] Submitted Activity: 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 at priority 30 with interval 21600 <private>
2026-03-15 18:55:51.099605-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:51.099629-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329' CurrentScore: 0.795345, ThresholdScore: 0.701929 DecisionToRun:1
2026-03-15 18:55:51.100398-0500 0x2c4c0    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] REQUESTING START: 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329
2026-03-15 18:55:51.153166-0500 0x2c45d    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Initiating XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 18:55:51.153905-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: beginning dispatch, activity name com.apple.XProtect.PluginService.agent.fast.scan, seqno 1
2026-03-15 18:55:51.153954-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640): found an activity with matching seqno 1
2026-03-15 18:55:51.154067-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_begin_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 18:55:51.154277-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: lower half, activity name com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), seqno from top half was 1
2026-03-15 18:55:51.154348-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 18:55:51.154369-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 18:55:51.154529-0500 0x2c45d    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Running XPC Activity (PID 9699): com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 18:55:51.154848-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 2
2026-03-15 18:55:51.154857-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 0
2026-03-15 18:55:51.154908-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 18:55:51.155198-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] STARTING activity 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329 <private>!
2026-03-15 18:55:51.160055-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329 has been running for 6.968180338541666e-05 minutes
2026-03-15 18:55:51.160454-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.76}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.590115, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.795345}
2026-03-15 18:55:52.323452-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 18:55:52.323457-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__ returned from handler: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 5
2026-03-15 18:55:52.323458-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 18:55:52.323466-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 18:55:52.323509-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 18:55:52.323536-0500 0x2c4c1    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 18:55:52.323671-0500 0x2c45d    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Completed XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 18:55:52.324321-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] COMPLETED 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329 at priority 30 <private>!
2026-03-15 18:55:52.324419-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle(activityGroup)] NO LONGER RUNNING 501:com.apple.XProtect.PluginService.agent.fast.scan:6F2329 ...Tasks running in group [com.apple.dasd.default] are 1!
2026-03-15 18:55:52.324977-0500 0x2c45d    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Rescheduling XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 18:55:52.325172-0500 0x2c45d    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] SUBMITTING: 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3
2026-03-15 18:55:52.325398-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 1
2026-03-15 18:55:52.325413-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_end_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 18:55:52.330797-0500 0x2c470    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:default] Submitted Activity: 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3 at priority 30 with interval 21600 <private>
2026-03-15 18:58:07.746598-0500 0x2c595    Error       0x32b31              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 18:58:07.770704-0500 0x2c803    Default     0x32b69              371    0    secd: [com.apple.security:signpost] BEGIN [127]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 18:58:07.772600-0500 0x2c803    Default     0x32b69              371    0    secd: [com.apple.security:signpost] END [127] 0.001908s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
2026-03-15 19:23:25.563950-0500 0x2ee1d    Error       0x34a4d              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 19:23:25.587823-0500 0x2f128    Default     0x34c80              371    0    secd: [com.apple.security:signpost] BEGIN [128]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 19:23:25.589763-0500 0x2f128    Default     0x34c80              371    0    secd: [com.apple.security:signpost] END [128] 0.001946s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
2026-03-15 20:18:10.298122-0500 0x342d3    Error       0x38ddc              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 20:18:10.321289-0500 0x34317    Default     0x39097              371    0    secd: [com.apple.security:signpost] BEGIN [129]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 20:18:10.323289-0500 0x34317    Default     0x39097              371    0    secd: [com.apple.security:signpost] END [129] 0.002002s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
2026-03-15 20:56:03.316846-0500 0x37818    Error       0x3b51b              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 20:56:03.340152-0500 0x3808a    Default     0x3b71e              371    0    secd: [com.apple.security:signpost] BEGIN [130]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 20:56:03.342546-0500 0x3808a    Default     0x3b71e              371    0    secd: [com.apple.security:signpost] END [130] 0.002400s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
2026-03-15 22:21:45.715581-0500 0x3b6b0    Error       0x3e981              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 22:21:45.738698-0500 0x3b784    Default     0x3e9c5              371    0    secd: [com.apple.security:signpost] BEGIN [131]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 22:21:45.741399-0500 0x3b784    Default     0x3e9c5              371    0    secd: [com.apple.security:signpost] END [131] 0.002705s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
2026-03-15 23:05:33.266155-0500 0x3f5d6    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:05:33.266590-0500 0x3f5d6    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:05:41.506997-0500 0x3f707    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:05:41.507269-0500 0x3f707    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:05:55.870323-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:05:55.870805-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:06:40.252269-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:06:40.252667-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:06:43.798856-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.55, Rationale: [{batteryLevel == 30 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.067917, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.784582}
2026-03-15 23:06:43.798878-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9' CurrentScore: 0.784582, ThresholdScore: 0.664113 DecisionToRun:1
2026-03-15 23:06:43.799600-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.55, Rationale: [{batteryLevel == 30 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.067917, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.784582}
2026-03-15 23:06:43.799641-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3' has compatibility score of -1.000000 with 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 (Started at <Not yet started>). Bailing out.
2026-03-15 23:06:43.799657-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 has been running for 0 minutes
2026-03-15 23:06:43.804655-0500 0x3f8ca    Default     0x0                  71     8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] REQUESTING START: 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9
2026-03-15 23:06:43.856003-0500 0x3f8ca    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Initiating XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 23:06:43.878964-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: beginning dispatch, activity name com.apple.XProtect.PluginService.daemon.fast.scan, seqno 1
2026-03-15 23:06:43.878967-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0): found an activity with matching seqno 1
2026-03-15 23:06:43.879198-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_begin_running: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0) seqno: 1.
2026-03-15 23:06:43.879297-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: lower half, activity name com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), seqno from top half was 1
2026-03-15 23:06:43.879331-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 2
2026-03-15 23:06:43.879335-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 2
2026-03-15 23:06:43.926119-0500 0x3f8ca    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Running XPC Activity (PID 9698): com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 23:06:43.928517-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), set activity state to 2
2026-03-15 23:06:43.928520-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), current state 2, pending state 0
2026-03-15 23:06:43.928854-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 4
2026-03-15 23:06:43.939830-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] STARTING activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 <private>!
2026-03-15 23:06:43.945830-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 has been running for 8.675058682759603e-05 minutes
2026-03-15 23:06:43.946188-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.55, Rationale: [{batteryLevel == 30 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.067917, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.784582}
2026-03-15 23:06:43.751273-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 has been running for -0.003121066093444824 minutes
2026-03-15 23:06:43.751774-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.55, Rationale: [{batteryLevel == 30 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.067917, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.784582}
2026-03-15 23:06:43.910111-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 5
2026-03-15 23:06:43.910116-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__ returned from handler: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), current state 2, pending state 5
2026-03-15 23:06:43.910116-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 1
2026-03-15 23:06:43.910125-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 4
2026-03-15 23:06:43.910228-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 5
2026-03-15 23:06:43.910280-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), 1
2026-03-15 23:06:43.910368-0500 0x3f8b3    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Completed XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 23:06:43.910996-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] COMPLETED 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 at priority 30 <private>!
2026-03-15 23:06:43.911087-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle(activityGroup)] NO LONGER RUNNING 0:com.apple.XProtect.PluginService.daemon.fast.scan:DC6CF9 ...Tasks running in group [com.apple.dasd.default] are 2!
2026-03-15 23:06:43.914974-0500 0x3f8b3    Default     0x0                  71     0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Rescheduling XPC Activity: com.apple.XProtect.PluginService.daemon.fast.scan (0x7f9e14113b40)
2026-03-15 23:06:43.915142-0500 0x3f8b3    Default     0x0                  71     8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] SUBMITTING: 0:com.apple.XProtect.PluginService.daemon.fast.scan:7B0598
2026-03-15 23:06:43.915332-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0), set activity state to 1
2026-03-15 23:06:43.915345-0500 0x2c41a    Default     0x0                  9698   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_end_running: com.apple.XProtect.PluginService.daemon.fast.scan (0x6000021740a0) seqno: 1.
2026-03-15 23:06:43.917182-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:default] Submitted Activity: 0:com.apple.XProtect.PluginService.daemon.fast.scan:7B0598 at priority 30 with interval 21600 <private>
2026-03-15 23:06:50.421402-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.55, Rationale: [{batteryLevel == 30 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.65}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
        {name: ThermalPolicy, policyWeight: 5.000, response: {Decision: Can Proceed, Score: 0.20, Rationale: }}
 ] sumScores:32.067917, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.660922}
2026-03-15 23:06:50.421453-0500 0x3f7e0    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3' CurrentScore: 0.660922, ThresholdScore: 0.664113 DecisionToRun:0
2026-03-15 23:06:59.347838-0500 0x3f8dc    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:07:02.436189-0500 0x3fb4d    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:07:08.238707-0500 0x3fbe9    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:12.051542-0500 0x3fb4d    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:14.129699-0500 0x3fd0d    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 33}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:26.392966-0500 0x3fbe9    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 33}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:41.195661-0500 0x3fedb    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:43.197415-0500 0x3fedb    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:22:53.398769-0500 0x3ffe4    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 1 AND darkWakeEligible == 1) AND wakeState == "DarkWake:cpu disk net "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:45:52.032168-0500 0x3ffe4    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: PowerNapPolicy, policyWeight: 5.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{(inADarkWake == 0 AND darkWakeEligible == 1) AND wakeState == "Sleep:<off> "}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:45:53.336124-0500 0x3ffe4    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:46:08.700092-0500 0x3ffe5    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Must Not Proceed, Score: 0.00, Rationale: [{deviceActivity == 1}]}}
 ], FinalDecision: Must Not Proceed}
2026-03-15 23:46:25.614981-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.51, Rationale: [{batteryLevel == 27 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.033432, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.783871}
2026-03-15 23:46:25.615005-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] '501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3' CurrentScore: 0.783871, ThresholdScore: 0.664113 DecisionToRun:1
2026-03-15 23:46:25.617100-0500 0x40198    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] REQUESTING START: 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3
2026-03-15 23:46:25.667755-0500 0x40198    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Initiating XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 23:46:25.668084-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: beginning dispatch, activity name com.apple.XProtect.PluginService.agent.fast.scan, seqno 1
2026-03-15 23:46:25.668088-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640): found an activity with matching seqno 1
2026-03-15 23:46:25.668104-0500 0x16e34    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_begin_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 23:46:25.668194-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_dispatch: lower half, activity name com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), seqno from top half was 1
2026-03-15 23:46:25.668205-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 23:46:25.668211-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 2
2026-03-15 23:46:25.668835-0500 0x40198    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Running XPC Activity (PID 9699): com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 23:46:25.669028-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 2
2026-03-15 23:46:25.669031-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 0
2026-03-15 23:46:25.669051-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 23:46:25.670671-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] STARTING activity 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3 <private>!
2026-03-15 23:46:25.673302-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] Activity 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3 has been running for 3.600120544433594e-05 minutes
2026-03-15 23:46:25.673837-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:scoring] 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3:[
        {name: BatteryLevelPolicy, policyWeight: 1.000, response: {Decision: Can Proceed, Score: 0.51, Rationale: [{batteryLevel == 27 AND pluggedIn == 0}]}}
        {name: DeviceActivityPolicy, policyWeight: 20.000, response: {Decision: Can Proceed, Score: 0.75}}
        {name: ChargerPluggedInPolicy, policyWeight: 10.000, response: {Decision: Can Proceed, Score: 0.50, Rationale: }}
 ] sumScores:38.033432, denominator:48.520000, FinalDecision: Can Proceed FinalScore: 0.783871}
2026-03-15 23:46:26.862454-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 23:46:26.862459-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] __XPC_ACTIVITY_CALLING_HANDLER__ returned from handler: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), current state 2, pending state 5
2026-03-15 23:46:26.862506-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 23:46:26.862563-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 4
2026-03-15 23:46:26.862607-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 5
2026-03-15 23:46:26.862641-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state: send new state to CTS: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), 1
2026-03-15 23:46:26.862748-0500 0x3ff73    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Completed XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 23:46:26.863331-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle] COMPLETED 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3 at priority 30 <private>!
2026-03-15 23:46:26.863409-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:lifecycle(activityGroup)] NO LONGER RUNNING 501:com.apple.XProtect.PluginService.agent.fast.scan:C525B3 ...Tasks running in group [com.apple.dasd.default] are 1!
2026-03-15 23:46:26.863677-0500 0x3ff73    Default     0x0                  360    0    UserEventAgent: (com.apple.cts) [com.apple.xpc.activity:Activities] Rescheduling XPC Activity: com.apple.XProtect.PluginService.agent.fast.scan (0x7fef5fc14f30)
2026-03-15 23:46:26.863803-0500 0x3ff73    Default     0x0                  360    8    UserEventAgent: (DuetActivityScheduler) [com.apple.duetactivityscheduler:client] SUBMITTING: 501:com.apple.XProtect.PluginService.agent.fast.scan:4D6C28
2026-03-15 23:46:26.863967-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_set_state_from_cts: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640), set activity state to 1
2026-03-15 23:46:26.863978-0500 0x402e5    Default     0x0                  9699   0    XProtect: (libxpc.dylib) [com.apple.xpc.activity:Client] _xpc_activity_end_running: com.apple.XProtect.PluginService.agent.fast.scan (0x6000005e8640) seqno: 1.
2026-03-15 23:46:26.869362-0500 0x402c7    Default     0x0                  120    8    dasd: [com.apple.duetactivityscheduler:default] Submitted Activity: 501:com.apple.XProtect.PluginService.agent.fast.scan:4D6C28 at priority 30 with interval 21600 <private>
2026-03-15 23:55:22.731024-0500 0x40ceb    Error       0x44097              141    0    loginwindow: (Security) [com.apple.security:tokenlogin] Invalid token login data property list, Error Domain=NSCocoaErrorDomain Code=3840 "Unexpected character = at line 1" UserInfo={NSDebugDescription=Unexpected character = at line 1, kCFPropertyListOldStyleParsingError=Error Domain=NSCocoaErrorDomain Code=3840 "Conversion of string failed." UserInfo={NSDebugDescription=Conversion of string failed.}}
2026-03-15 23:55:22.754725-0500 0x40d80    Default     0x4476c              371    0    secd: [com.apple.security:signpost] BEGIN [132]: SOSSignpostNameSOSCCHandleUpdateMessage  enableTelemetry=YES
2026-03-15 23:55:22.757053-0500 0x40d80    Default     0x4476c              371    0    secd: [com.apple.security:signpost] END [132] 0.002333s: SOSSignpostNameSOSCCHandleUpdateMessage  SOSSignpostNameSOSCCHandleUpdateMessage=__##__signpost.telemetry#____#number1#_##_#1##__##
--------------------------------------------------------------------------------------------------------------------
Log      - Default:        776, Info:                0, Debug:             0, Error:        251, Fault:          0
Activity - Create:           0, Transition:          0, Actions:           0
Joshs-MacBook-Pro:dotfile-vnext joshc$ log show --predicate 'subsystem == "com.apple.security" OR eventMessage CONTAINS "XProtect"' --last 24h^C

xattr -l "/Applications/Microsoft Remote Desktop.app" 2>/dev/null | grep -i quarantine || echo "no com.apple.quarantine attr"
